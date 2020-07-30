----------------------------------------------------------
# Azure Web App For Containers configured with Azure AD B2C, Azure Front Door, Azure DNS Zone (Custom Domain with DigiCert Certificate)


# High Level Architecture Diagram:


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer01.png)


# Configuration Flow :

------------------------------------------------------------------------------
# 1. Create new infrastructure using Azure Terraform

```
terraform init
terrafom plan
terrafrom apply

The following Azure Service will be created:
 - AppService - Linux
 - Azure DNS Zone
 - Azure Front Door (With WAF and Policy)
 - Azure CDN
 - Azure Storage Account 
``` 
------------------------------------------------------------------------------
# 2. Configure Azure DNS Zone, edit Name Server of GoDaddy to utilize the Azure Name servers. Add "CAA" for DigiCert (use for Azure FrontDoor Custom Domain Certificate Management)
	 
![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer02.png)


------------------------------------------------------------------------------
# 2.1 Configure Azure Front Door to utilize Custom Domain and Digicert Certificate

    Verify and ensure the FrontDoor certificate Management Type is set to "FrontDoor Manage"

![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer03.png)


------------------------------------------------------------------------------
# 3. Create a Azure B2C Tenant

https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant

-----------------------------------------------------------------------------
# 3.1 Create Userflow (Signin,SignUp and Profile Edit) 

https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows
 
------------------------------------------------------------------------------
# 3.2 Create new  ASP.net Core web app with AD B2C and Docker configurations.

![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer04.png)
		
------------------------------------------------------------------------------
# 3.3 Create MVC Controller with Views, Using Entity Framework. Make sure application can run in IIS Express and Docker.

![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer05.png)


------------------------------------------------------------------------------
# 3.4 Tag Image and push to Docker Hub repository

```
docker login
User Name : Your Docker Hub User Name	
Password  : Your Docker Hub Password
	

docker ps
docker images  

docker tag phproject01 gbbuenaflor/webapp4container01-app:v1
docker push gbbuenaflor/webapp4container01-app:v1
```
  
------------------------------------------------------------------------------
# 4. Test The Web Application and view the results

```
    Authentication flows and application scenario:
     Scenario                 : Web app that sign in users
     Linux                    : ASP.net Core
     OAuth 2.0 flow and grant : Authorization code
     Audience                 : Work or school accounts, personal accounts, and Azure AD B2C

     Note: App Service Plan - Linux is describe in this post
```

![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer06.png)


```
   -	User will Login or Register new account to the system
   -	Once validated by ADB2C
      -	If user passed authentication the system will redirect traffic to the application.
      -	If user fail authentication the system will redirect traffic to denied ui page.
```

 
## -  View Docker Image (from Docker Hub) running inside the App Service


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer09.png)


 
## -  View ADB2C UI, UserFlow (SingIn , Edit Profile)


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer07.png)



## -  Once sign-up, user profile is added in the Azure B2C


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer10.png)



## -  View the ASP.Net Core Web application running under Azure FrontDoor configured with a Custom Domain and valid DigiCert certificate.


![Image description](https://github.com/GBuenaflor/01azure-appservices-webapp4container-b2c/blob/master/Images/GB-WebAppForContainer08.png)

 


</br>
Link to other Microsoft Azure projects
https://github.com/GBuenaflor/01azure
</br>


Note: My Favorite > Microsoft Technologies.
