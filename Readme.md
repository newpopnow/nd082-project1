# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
In this project, you will build a web server by Packer then deploy a cluster of servers from Packer image with a Load balancer to manage incomming traffic

Diagram:
![alt](/project-1.jpg)

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
#### Step 1: Build a Packer image

##### 1. To create Azure principle service:
```
az ad sp create-for-rbac --role contributor --scopes /subscriptions/mySubscriptionID
```
Take note "appId" and "password" output for next step

##### 2. Create a Resource group:
```
az group create --name "PackerImage-rg" --location eastus
```

##### 3. Build Packer template

Open file server.json with your text editor, update these value (from previous):
```
"client_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
"client_secret": "ppppppp-pppp-pppp-pppp-ppppppppppp",
"tenant_id": "zzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
"subscription_id": "yyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyy",
```
Save server.json and run:
```
packer build server.json
```
To verify Image has been created, run:
```
az image list
```

#### Step 2: To deploy server cluster

Run:
```
terraform plan -output tf.plan
terraform apply
```
### Output
The result will output an Public IP Address of Load balancer, open it and you will see nginx default homepage. Well done!

### Cleanup Resources
To remove resources, run following command:
```
terraform destroy -auto-approve
az image delete -g PackerImage-rg -n myPackerImage
az group delete --name PackerImage-rg
```
