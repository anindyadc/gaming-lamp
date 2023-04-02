#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login
#
# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script

export YOURSUBSCRIPTIONID=fc69814a-eec6-4f04-9568-e1f1acf4619c
export RESOURCEGROUPNAME=mylampstack
export REGIONNAME=eastus2
export LOGINUSERNAME=eastus2
#export LOGINPASSWORD=N0tReCoMM3ND3DUseSSH

# Variables for creating the VM that will serve as a foundation for the VMSS golden image
export VMNAME=myVirtualMachine
export IMAGE=Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest
export VMSIZE=Standard_B1s
export VMDATADISKSIZEINGB=5
#############################################################################################

#############################################################################################

# Connect to Azure
#az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

# Create a resource group
echo Creating a resource group named $RESOURCEGROUPNAME in the region $REGIONNAME
az group create \
 --name $RESOURCEGROUPNAME \
 --location $REGIONNAME

# Create a virtual machine
echo Creating a virtual machine named $VMNAME with size $VMSIZE - it will take a few minutes
az vm create \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMNAME \
 --image $IMAGE \
 --size $VMSIZE \
 --admin-username $LOGINUSERNAME \
 --data-disk-sizes-gb $VMDATADISKSIZEINGB \
 --generate-ssh-keys

# Open the port 80
echo Opening port 80 in the virtual machine named $VMNAME
az vm open-port \
 --port 80 \
 --priority 900 \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMNAME

# Open the port 443
echo Opening port 443 in the virtual machine named $VMNAME
az vm open-port \
 --port 443 \
 --priority 901 \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMNAME
