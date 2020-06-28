----------------------------------------------------------
# Azure Web App For Containers configured with Azure AD B2C and Custom Domain


# High Level Architecture Diagram:


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer01.png)


# Configuration Flow :

------------------------------------------------------------------------------
# 1. Create new the infrastructure using Azure Terraform

 - AppService - Linux
 - Azure DNS Zone
 - Azure Front Door (With WAF and Policy)
 - Azure CDN
 - Azure Storage Account
 
 
------------------------------------------------------------------------------
# 2. Configure Azure DNS Zone, edit Name Server of GoDaddy to utilize the Azure Name servers.
     Add CAA for DigiCert (use to Azure FrontDoor Custom Domain Certificate Management)
	 
![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer02.png)


------------------------------------------------------------------------------
# 2.1 Configure Azure Front Door to utilize Custom Domain and Digicert Certificate

    Verify and ensure the FrontDoor certificate Management Type is set to "FrontDoor Manage"

![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer03.png)


------------------------------------------------------------------------------
# 3. Create a Azure B2C Tenant, Create a WEb app and register to AD B2C
     https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant

------------------------------------------------------------------------------
# 3.1 Create a ASP.net Core web app with AD B2C and Docker configurations.

![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer04.png)

	 
     Create New ASP.NET Core Web Application Project.

![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer05.png)

	
-----------------------------------------------------------------------------
# 3.2 Create Userflow (Signin,SignUp and Profile Edit) 

https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows
 
 
------------------------------------------------------------------------------
# 4. Test The Web Application and view the results

    Authentication flows and application scenario:
     Scenario                 : Web app that sign in users
     Linux                    : ASP.net Core
     OAuth 2.0 flow and grant : Authorization code
     Audience                 : Work or school accounts, personal accounts, and Azure AD B2C

     Note: App Service Plan - Linux is describe in this post
	 
![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer06.png)


   - 1.User will Login or Register new account to the system
   - 2.Once validated by ADB2C
      - 3.If user passed authentication the system will redirect traffic to the application.
      - 3.If user fail authentication the system will redirect traffic to denied ui page.


 
# View ADB2C UI, UserFlow (SingIn , Edit Profile)


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer07.png)


# View the ASP.Net Core Web application running under Azure FrontDoor with valid DigiCert certificate.


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/GB-WebAppForContainer08.png)

 



Note: My Favorite > Microsoft Technologies.
