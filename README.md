Simple Web App Deployment with Terraform and Azure Cloud and Devops
Overview
A simple  3 tier web application can be hosted in the Azure Cloud Enviroment.
Azure Key Vault is used for secrets management.
Azure Storage Account is used for state storage.
Application Insights is used for monitoring.
An additional Azure Storage Account is created to store log data, including Key Vault diagnostic log data.
Tools used include VSCode with the Terraform extension and the VSCode terminal.
Steps to Set Up

Step 1: Create App Registration and Service Principal
Create an app registration that automatically creates a Service Principal and assigns it the Contributor role for your subscription. Example using Azure CLI:
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/75e2cef5-d3ca-42ff-8b0d-4dab256b9453"

Step 2: Define Environment Variables
If you are not using Terraform Cloud, pass the variables in your terminal:

$Env:ARM_CLIENT_ID = "******-******-******-******-********"
$Env:ARM_CLIENT_SECRET = "******-******-******-******-********"
$Env:ARM_SUBSCRIPTION_ID = "******-******-******-******-********"
$Env:ARM_TENANT_ID = "******-******-******-******-********"
To check all environment variables:
dir env:

Step 3: Set Up Storage Account for State File
Create a storage account to store the Terraform state file:

az storage account create --name <your storage account name> --resource-group <your resource group name> --location westus2 --sku Standard_LRS --allow-blob-public-access true

Step 4: Create Blob Container
Create a blob container inside your storage account:

az storage container create --name <your blob container name> --account-name <your storage account name> --public-access off

Step 5: Configure Access Policy
Set the access policy in Azure Key Vault using object IDs for service connection, user, and web app. These IDs can be copied from the Azure Portal.

Step 6: DevOps Configuration
Ensure you have the Azure CLI and Azure DevOps extension installed:

az login
az devops configure --defaults organization=https://dev.azure.com/YOUR_ORGANIZATION
az devops project create --name "Your Project Name" --description "Your project description" --visibility public --process agile --source-control git
Step 7: Connect Git Project to Azure DevOps
Connect your Git project to your Azure DevOps project.

Step 8: Connect Service Connection in Azure DevOps
If you already have a service connection, use the existing one. If not, create a new service connection in Azure. Create a secret key and provide the service principal key, ID, tenant ID, and subscription ID.

Step 9: Give Git YAML File Access to DevOps Pipeline
Go to the pipeline section in Azure DevOps, create a pipeline, and give it access to the YAML file in your Git repository. Select the existing YAML file from Git and save it in DevOps.

Step 10: Install Terraform Extension in Azure DevOps
Install the Terraform extension in Azure DevOps from the organization settings. Choose the one from Microsoft DevLabs.

Before executing in the pipeline, ensure terraform init and all the above setups are done. Up to this point, your code should run and create all the resources.

Step 11: Trunk-Based Development PR Validation
Set up pull request (PR) validation for trunk-based development:

Go to branch policies in the main branch inside your Azure DevOps git or if you have used github 
Go to the settings branches add new ruleset and add new branch 

Require a minimum number of reviewers (set to 1) and allow requestors to approve in azure devops git .
Create a new branch, push the PR validation YAML file. Check on Azure DevOps git or github, create a pull request, review  and merge it.


Go to pipeline create new pipeline for pr-validation and point that to your existing git yaml pipeline.
now whenever new pull request is created it should automatically run the pipeline.

Acknowledgements
Thanks to:

ned1313 for terraform-tuesdays/2021-05-25-ADO
SkillBuilderZone for SimpleApp_Terraform/