# Setup AKS cluster, ACR and a host for DevOps agents

> This is a guide for how to use the scripts to easely setup a AKS cluster, ACR and a host

**What the scripts do**

- Install azCLI and kubectl
- Connect to Azure with terminal
- Create and deploy Azure cluster, Azure Container Registry and a VM for hosting agents
- Configure self-hosted DevOps agents
- Delete all content in a cluster namespace

---

## Table of Contents

- [Preinstallation](#Preinstallation)
- [Clone](#Clone)
- [Contributing](#contributing)
- [Delete all in cluster](#Delete-all)

---

## Preinstallation

- You will need all the scripts in the folder hpr112script


### Clone

- Clone this repo to your local machine using `https://github.com/bachelor112hpr/eShopOnContainers`

---

## Contributing

> To get started...

### Step 1

- Log in at the machine you want to use for administration

### Step 2

- 👯 Clone og download this repo to your local machine using `https://github.com/bachelor112hpr/eShopOnContainers`
- Open PowerShell as Administrator and navigate to the folder hpr112script in the repo


### Step 3

- Run the script install-azCLI-kubectl. ps1
  (If you dont already installed azCLI and kubectl, the computer will reboot)

### Step 4

- After reboot, run the script deployAzure.ps1
- This use the four scirpts Connect-to-Azure.ps1, createAks.ps1, create-ACR.ps1 and creatVM.ps1
- Some configuration is required, and you will be asked if you want to setup all three or just one or two of the services


### Step 5

- If you choosen to create a hosting VM you can now configure agents to run on this VM
- Make sure you are logged in to the linuxVM

#### Step 5.1 
-run command chmod +x LinuxAgentHost.sh

#### Step 5.2
- run script LinuxAgentHost.sh
- Some configuration is required

### At this point you should have a cluster, a registry, a Linux VM up an running in Azure, and some agents hosted on the Linux VM.

---

### Delete-all

- The script delete-all.ps1 can be used to delete all content in a namespace in the cluster. just run the script with
  parametes for clustername, resourcegroup and namespace. If you dont define a namespace it will delete all i namespace: default

---

