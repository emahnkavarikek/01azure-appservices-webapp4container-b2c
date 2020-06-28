#----------------------------------------------------
#  Replace correct values or configure values in Azure DevOps variables :
#
#  - subscription_id  
#  - client_id  
#  - client_secret  
#  - tenant_id  
#  - ssh_public_key  
#  - access_key
#---------------------------------------------------- 

variable subscription_id { 
      default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  
 }

variable client_id       {
      default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"   # AzureTerraform 
 }

variable client_secret   {
      default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"   # AzureTerraform 
 }

variable tenant_id       {
      default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  
 }
 

variable ssh_public_key {
   default = "azure_rsa.pub"
} 
   
    
#----------------------------------------------------
# Other Variables
#----------------------------------------------------
    
variable environment {
    default = "Dev"
}

variable location {
    default = "eastus"
} 
   
variable resource_group {
  default = "Dev01-AppServices-RG"
} 
 