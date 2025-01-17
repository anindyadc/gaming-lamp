#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login

# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script
export YOURSUBSCRIPTIONID=fc69814a-eec6-4f04-9568-e1f1acf4619c
export RESOURCEGROUPNAME=mylampstack
export REGIONNAME=eastus2
export PREFIX=myGameBackend
export VNETNAME=${PREFIX}VNET


# Variables for creating the storage account and the container
export RANDOMNUMBER=`head -200 /dev/urandom | cksum | cut -f2 -d " "`
export STORAGENAME=${PREFIX}STRG
export STORAGENAMELOWER=${STORAGENAME,,}
export STORAGENAMEUNIQUE=${STORAGENAMELOWER}${RANDOMNUMBER}
export STORAGESKU=Standard_LRS
export STORAGECONTAINERNAME=${STORAGENAMELOWER}cntnr
export STORAGESUBNETNAME=${STORAGENAME}Subnet
export STORAGESUBNETADDRESSPREFIX='10.0.3.0/24'
export STORAGERULENAME=${STORAGENAME}Rule
#############################################################################################

# Connect to Azure
#az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Creating a storage account named $STORAGENAMEUNIQUE
az storage account create \
 --resource-group $RESOURCEGROUPNAME \
 --name $STORAGENAMEUNIQUE \
 --sku $STORAGESKU \
 --location $REGIONNAME

echo Getting the connection string from the storage account
export STORAGECONNECTIONSTRING=`az storage account show-connection-string -n $STORAGENAMEUNIQUE -g $RESOURCEGROUPNAME --query connectionString -o tsv`

echo Creating a storage container named $STORAGECONTAINERNAME into the storage account named $STORAGENAMEUNIQUE
az storage container create \
 --name $STORAGECONTAINERNAME \
 --connection-string $STORAGECONNECTIONSTRING

echo Enabling service endpoint for Azure Storage on the Virtual Network and subnet
az network vnet subnet create \
 --resource-group $RESOURCEGROUPNAME \
 --vnet-name $VNETNAME \
 --name $STORAGESUBNETNAME \
 --service-endpoints Microsoft.Storage \
 --address-prefix $STORAGESUBNETADDRESSPREFIX

echo Adding a network rule for a virtual network and subnet
STORAGESUBNETID=`az network vnet subnet show --resource-group $RESOURCEGROUPNAME --vnet-name $VNETNAME --name $STORAGESUBNETNAME --query id --output tsv`
az storage account network-rule add --resource-group $RESOURCEGROUPNAME --account-name $STORAGENAMEUNIQUE --subnet $STORAGESUBNETID
