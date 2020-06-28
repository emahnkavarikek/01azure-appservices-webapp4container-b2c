#######################################################
# Azure Terraform - Infrastructure as a Code (IaC)
#  
#
# - Azure DNS Zone 
# - Azure Front Door 
# - Azure CDN  
# - Azure App Services Plan (Linux) 
#     - WebApp For Container
#     - Docker Container for Docker Hub   
# - Azure SQL Server
#   - Azure SQL Database (Single)
#   - Azure Storage Account
#
# ----------------------------------------------------
#  Initial Configuration
# ----------------------------------------------------
# - Run this in Azure CLI
#   az login
#   az ad sp create-for-rbac -n "AzureTerraform" --role="Contributor" --scopes="/subscriptions/[SubscriptionID]"
#
# - Then complete the variables in the variables.tf file
#   - subscription_id  
#   - client_id  
#   - client_secret  
#   - tenant_id  
#   - ssh_public_key   
#
####################################################### 
#----------------------------------------------------
# Azure Terraform Provider
#----------------------------------------------------

provider "azurerm" { 
  features {}
  version = ">=2.0.0"  
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id 
}

#----------------------------------------------------
# Resource Group
#----------------------------------------------------

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group
  location = var.location
}
     

#----------------------------------------------------
#  azurerm_dns_zone , azurerm_dns_cname_record
#---------------------------------------------------- 

resource "azurerm_dns_zone" "azurerm_dns_zone01" {
  name                = "az-frontdoor01.azurefd.net"# "aks01-web.domain.net"
  resource_group_name = azurerm_resource_group.resource_group.name

}
 
resource "azurerm_dns_cname_record" "azurerm_dns_cname_record01" {
  name                = "gb"
  resource_group_name = azurerm_resource_group.resource_group.name

  zone_name           = azurerm_dns_zone.azurerm_dns_zone01.name
  ttl                 = 3600
  # Choose between target_resource_id or record
  #target_resource_id = azurerm_frontdoor.az-frontdoor01.id  #azurerm_dns_cname_record.target.id
  record              =  "az-frontdoor01.azurefd.net" # "gbdev.azurefd.net"  #  either record OR target_resource_id must be specified, but not both.
 
} 
 
 
resource "azurerm_dns_caa_record" "azurerm_dns_caa_record01" {
  name                = "azurerm_dns_caa_record01"
  zone_name           = azurerm_dns_zone.azurerm_dns_zone01.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300

  record {
    flags = 0
    tag   = "issue"
    value = "digicert.com"  # "letsencrypt.org"
  }
    record {
    flags = 0
    tag   = "iodef"
    value = "mailto:<YourEmailAddress>"
  }
}


#----------------------------------------------------
#  azurerm_cdn_profile , azurerm_cdn_endpoint
#----------------------------------------------------

resource "azurerm_cdn_profile" "az-cdnprofile01" {
  name                = "az-cdnprofile01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard_Microsoft" # "Standard_Verizon" # Standard_Akamai Standard_ChinaCdn Standard_Verizon Standard_Microsoft Premium_Verizon
}

resource "azurerm_cdn_endpoint" "az-cdnendpoint01" {
  name                = "az-cdnendpoint01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  profile_name        = azurerm_cdn_profile.az-cdnprofile01.name

  origin {
    name              = "az-cdnorigin01"       # [Name].azureedge.net
    host_name         = "azstorageaccount02.blob.core.windows.net" # map to storage account (blob container) #"az-app-service01.azurewebsites.net"	 
	#origin_path      = /
	http_port         = 80
	https_port        = 443	
  }
  origin_host_header  =  "azstorageaccount02.blob.core.windows.net" # "az-app-service01.azurewebsites.net"
  
} 
 
#----------------------------------------------------
#  azurerm_frontdoor_firewall_policy
#----------------------------------------------------
resource "azurerm_frontdoor_firewall_policy" "azFrontDoorFirewallPolicy" {
  name                              = "azFrontDoorFirewallPolicy"
  resource_group_name = azurerm_resource_group.resource_group.name

  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://az-app-service01.azurewebsites.net" # "https://gb.aks01-web.domain.net"
  custom_block_response_status_code = 403
  custom_block_response_body        = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="

  custom_rule {
    name                           = "Rule1"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
    }
  }

  custom_rule {
    name                           = "Rule2"
    enabled                        = true
    priority                       = 2
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24"]
    }

    match_condition {
      match_variable     = "RequestHeader"
      selector           = "UserAgent"
      operator           = "Contains"
      negation_condition = false
      match_values       = ["windows"]
      transforms         = ["Lowercase", "Trim"]
    }
  }

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"

    exclusion {
      match_variable = "QueryStringArgNames"
      operator       = "Equals"
      selector       = "not_suspicious"
    }

    override {
      rule_group_name = "PHP"

      rule {
        rule_id = "933100"
        enabled = false
        action  = "Block"
      }
    }

    override {
      rule_group_name = "SQLI"

      exclusion {
        match_variable = "QueryStringArgNames"
        operator       = "Equals"
        selector       = "really_not_suspicious"
      }

      rule {
        rule_id = "942200"
        action  = "Block"

        exclusion {
          match_variable = "QueryStringArgNames"
          operator       = "Equals"
          selector       = "innocent"
        }
      }
    }
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
  }
}


#----------------------------------------------------
#  azurerm_frontdoor
#----------------------------------------------------

resource "azurerm_frontdoor" "az-frontdoor01" {
  name                = "az-frontdoor01"
  resource_group_name = azurerm_resource_group.resource_group.name
  
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name                  = "RoutingRule01"
    accepted_protocols    = ["Http", "Https"]
    patterns_to_match     = ["/*"]
    frontend_endpoints    = ["FrontendEndpoint01"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"  # HttpOnly, HttpsOnly, or MatchRequest
      backend_pool_name   = "BackendPool01"
	  cache_enabled       = "false"
    }
  }

  backend_pool_load_balancing {
    name                             = "BackendPoolLoadBalancing01"
	sample_size                      = 4
	successful_samples_required      = 2
	additional_latency_milliseconds  = 0
  }

  backend_pool_health_probe {
    name                 = "BackendPoolHealthProbe01"
	path                 = "/"
	protocol             = "Https" # 443
	probe_method         = "HEAD"
	interval_in_seconds  = 30  # Default 120s
  }

  backend_pool {
    name = "BackendPool01"
    backend {
	  enabled      = "true"
      host_header  = "az-app-service01.azurewebsites.net" # Appservice URL
      address      = "az-app-service01.azurewebsites.net" #"gb.aks01.domain.net"
      http_port    = 80
      https_port   = 443
	  priority     = 1
	  weight       = 50
    }

    load_balancing_name = "BackendPoolLoadBalancing01"
    health_probe_name   = "BackendPoolHealthProbe01"
  }

  frontend_endpoint {
    name                              = "FrontendEndpoint01"
    host_name                         = "az-frontdoor01.azurefd.net" #"aks01-web.domain.net"
    custom_https_provisioning_enabled = false # for a custom domain associated with the Front Door
#	custom_https_configuration  {
#	  certificate_source  = "FrontDoor" # Use FrontDoor Generated Certificate
#	}
	session_affinity_enabled          = false
	session_affinity_ttl_seconds      = 0 
	web_application_firewall_policy_link_id  = azurerm_frontdoor_firewall_policy.azFrontDoorFirewallPolicy.id
  }
  
  depends_on = [azurerm_dns_zone.azurerm_dns_zone01,azurerm_frontdoor_firewall_policy.azFrontDoorFirewallPolicy, azurerm_app_service_plan.az-app-service01-plan01 ]
 
}
#----------------------------------------------------
#  azurerm_sql_server , azurerm_sql_database
#----------------------------------------------------

resource "azurerm_sql_server" "az-sqlserver01" {
  name                = "az-sqlserver01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
   
  version                      = "12.0"
  administrator_login          = "dbadmin"  
  administrator_login_password = "Your Pass word here"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_account" "azstorageaccount02" {
  name                     = "azstorageaccount02"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "az-sqldb01" {
  name                = "az-sqldb01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  server_name         = azurerm_sql_server.az-sqlserver01.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.azstorageaccount02.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.azstorageaccount02.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
 
  tags = {
    environment = "production"
  }
}


resource "azurerm_sql_firewall_rule" "az-sqlfirewallrule01" {
  name                = "FirewallRule1"
  resource_group_name = azurerm_resource_group.resource_group.name
  
  server_name         = azurerm_sql_server.az-sqlserver01.name
  start_ip_address    = "0.0.0.0" # Allow access to Azure services   "10.0.17.62"  # Client IP
  end_ip_address      = "0.0.0.0" #    "10.0.17.62"
}


#----------------------------------------------------
#  azurerm_app_service_plan
#----------------------------------------------------
 resource "azurerm_app_service_plan" "az-app-service01-plan01" {
  name                = "az-app-service01-plan01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  
  reserved            = true  #  Linux   
  kind = "Linux"
  
  sku {
    tier = "Basic"  # PremiumV2
    size = "B1"     # P1v2
  }
}
  
#----------------------------------------------------
#  azurerm_app_service
#----------------------------------------------------

resource "azurerm_app_service" "az-app-service01" {
  name                = "az-app-service01"  
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.az-app-service01-plan01.id
  
  app_settings = {
  
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    ASPNETCORE_ENVIRONMENT = "Production" # Dev # Staging
     
    #-----------------------
	# Web App For Container - using Docker Hub Repository
	#-----------------------
	
    DOCKER_REGISTRY_SERVER_URL        =  "https://index.docker.io/v1/" ,     
    DOCKER_REGISTRY_SERVER_USERNAME   =  "Your Docker UserName" ,          
    DOCKER_REGISTRY_SERVER_PASSWORD   =  "Your Docker Password" ,                     
    DOCKER_CUSTOM_IMAGE_NAME          =  "DOCKER|gbbuenaflor/webapp4container01-app:v1" ,  # Your Image Here
	
	##-----------------------
	## Web App For Container - Using Azure ACR 
	##-----------------------
    #DOCKER_REGISTRY_SERVER_URL        =  azurerm_container_registry.az-app-service01-plan01.login_server, # https://<server-name>.azurecr.io
    #DOCKER_REGISTRY_SERVER_USERNAME   =  azurerm_container_registry.admin_username,
    #DOCKER_REGISTRY_SERVER_PASSWORD   =  azurerm_container_registry.admin_password,
    #DOCKER_CUSTOM_IMAGE_NAME          =  <server-name>.azurecr.io/<image-name>:<tag>
		
	}
 
   connection_string {
   
    name  = "DataBaseContextConnection"
    type  = "SQLServer"
    value = "Server=tcp:az-sqlserver01.database.windows.net,1433;Database=az-sqldb01;MultipleActiveResultSets=False;User ID=dbadmin;Password=4-v3ry-53cr37-p455w0rd;Encrypt=True;" # "Server=some-server.mydomain.com;Integrated Security=SSPI"
}

   connection_string {
   
    name  = "DataBaseContextConnection_Staging"
    type  = "SQLServer"
    value = "Server=tcp:az-sqlserver01.database.windows.net,1433;Database=az-sqldb02_staging;MultipleActiveResultSets=False;User ID=dbadmin;Password=4-v3ry-53cr37-p455w0rd;Encrypt=True;" # "Server=some-server.mydomain.com;Integrated Security=SSPI"
}

   connection_string {
   
    name  = "DataBaseContextConnection_Dev"
    type  = "SQLServer"
    value = "Server=tcp:az-sqlserver01.database.windows.net,1433;Database=az-sqldb03_Dev;MultipleActiveResultSets=False;User ID=dbadmin;Password=4-v3ry-53cr37-p455w0rd;Encrypt=True;" # "Server=some-server.mydomain.com;Integrated Security=SSPI"

	}
 
  site_config {

    #-----------------------
	# Web App For Container - Deploying Single Container
	#-----------------------
    ## linux_fx_version = "DOCKER|nginx"  	                            # Load Image on start (From Dockerhub Public Repo)  
	linux_fx_version = "DOCKER|gbbuenaflor/webapp4container01-app:v1"   # "DOCKER|gbbuenaflor/web01aks:308" # (From Dockerhub)  
	
    #-----------------------
	# Web App For Container - Deploying Multiple Containers using Docker Compose
	#-----------------------
	#linux_fx_version = "COMPOSE|${filebase64("compose.yml")}" 
    #lifecycle {       
    #ignore_changes = [
    #  "site_config.0.linux_fx_version", # deployments are made outside of Terraform
    #]
    #} 
	
    always_on         = "true"
  }
  
  #  depends_on = [azurerm_container_registry.az_container_registry01,azurerm_container_registry_webhook]
}
  