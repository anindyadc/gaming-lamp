#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login

# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# Ensure that you have installed in the virtual machine all you need prior to creating the image
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script
export YOURSUBSCRIPTIONID=fc69814a-eec6-4f04-9568-e1f1acf4619c
export RESOURCEGROUPNAME=mylampstack
export REGIONNAME=eastus2

# Variables for creating the golden image
export VMNAME=myVirtualMachine
export GOLDENIMAGENAME=myGoldenImage
#############################################################################################

#############################################################################################

# Connect to Azure
#az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Creating the golden image named $GOLDENIMAGENAME using $VMNAME as a source
az image create \
 --resource-group $RESOURCEGROUPNAME \
 --source $VMNAME \
 --name $GOLDENIMAGENAME \
 --os-type Linux
