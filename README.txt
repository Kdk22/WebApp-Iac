Simple web app is hosted. Iac terraform tool is used to create azure resoures
Azure Key Vault for Secrets Management, storage accout for state storage is already created , Applicatoin Insight is used for monitoring
Here i have created one extra storage account to store the log data. Key Vault diagonistic log data are stored in here.
Tools I used is VSCode and i have installed terraform in it and i have used the vs code terminal.

Step : 1
Create App registration that creates the SP automatically and give it a permission as a Contributor to your subscription.
for eg like this in cli :  az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/75e2cef5-d3ca-42ff-8b0d-4dab256b9453"


Step : 2
you can define the enviorment variable in Terraform cloud if you have used the terraform cloud workspace but in this app i have not used . so I have passed the variables in my terminal
$Env:ARM_CLIENT_ID = "******-******-******-******-********"
$Env:ARM_CLIENT_SECRET = "******-******-******-******-********"
$Env:ARM_SUBSCRIPTION_ID = "******-******-******-******-********"
$Env:ARM_TENANT_ID = "******-******-******-******-********"

to check all env variables you can do is 
dir env:

Step :3 Step up Storage account to store state file
 az storage account create   --name <your storage account name> --resource-group <your resource group name> --location westus2 --sku Standard_LRS --allow-blob-public-access true 

 step : 4 Create Blob container inside your storage account
 az storage container create --name <your blob account name> --account-name <your storage account name>  --public-access off

step :5 Object Id
Here in access policy i have passed the object id . these are copied from Azure Portal
One for service connection, one for user and one for web app to access the key vault . You can change it according to your requirement.

step : 6 Devops Configuration
First, make sure you have the Azure CLI and Azure DevOps extension installed. If not, you can install
az login

az devops configure --defaults organization=https://dev.azure.com/YOUR_ORGANIZATION

az devops project create --name "Your Project Name" --description "Your project description" --visibility public --process agile --source-control git 

Step: 7 Connect your git project to your azure Devops 

Step: 8 Connect Service Connection in Azure Devops
i already have service connection so i will use existing sc. if not create in azure , create secret key as well 
pass service principle key , id , tenant id , subscription id
Application (client) ID = Service Principal Id
  client secret value = Service principal key

Step: 9 Give git yaml file access to devops pipeline
go to pipeline and create pipeline . here you need to give access to pipeline to access that yaml file in the git.
 so select the existing yaml file from git and save in devops

 Step : 10 Install Terraform extension in azure devops
 go to organization settings and install terraform extension in azure devops
i choosed one from Microsoft DevLabs

Before you execute in pipeline make sure terraform init and all the above set up is done.
Upto here your code should run and all the resources should be created.



Thanks to 
ned1313 for 
terraform-tuesdays/2021-05-25-ADO
and 
SkillBuilderZone for
SimpleApp_Terraform/
projects.
