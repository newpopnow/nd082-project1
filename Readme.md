# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
In this project, you will build a web server by Packer then deploy a cluster of servers from Packer image with a Load balancer to manage incomming traffic

### Getting Started
In order to build, you will need to:
* Clone this repository
* Modify variables as your enviroment
* Run the code

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
Create Azure principle service

```
az ad sp create-for-rbac --role contributor --scopes /subscriptions/mySubscriptionID
```

Note appId and password output for future use

Build Packer template
1. Create Resource group
```az group create --name "PackerImage-rg" --location eastus```
Edit server.json

```packer build server.json```

Match Resource group name, image name
Create a service principle in Azure
Modify client_id, client_secret, subscription_id as yours
Run packer build server.json

To deploy server cluster

Run
terraform plan -output tf.plan
terraform apply

### Output
The result will output an Public IP Address of Load balancer 
