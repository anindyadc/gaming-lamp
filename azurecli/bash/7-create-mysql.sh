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
export LOGINUSERNAME=azureuser
export PREFIX=myGameBackend

export VNETNAME=${PREFIX}VNET

# Variables for setting up the MySQL database
export RANDOMNUMBER=`head -200 /dev/urandom | cksum | cut -f2 -d " "`
export MYSQLNAME=${PREFIX}MySQL
export MYSQLNAMELOWER=${MYSQLNAME,,}
export MYSQLNAMEUNIQUE=${MYSQLNAMELOWER}${RANDOMNUMBER}
export MYSQLUSERNAME=azuremysqluser
export MYSQLPASSWORD=CHang3thisP4Ssw0rD
export MYSQLDBNAME=gamedb
export MYSQLBACKUPRETAINEDDAYS=7
export MYSQLGEOREDUNDANTBACKUP=Disabled
export MYSQLSKU=GP_Gen5_2
export MYSQLSTORAGEMBSIZE=51200
export MYSQLVERSION=5.7
export MYSQLREADREPLICANAME=${MYSQLNAMEUNIQUE}Replica
export MYSQLREADREPLICAREGION=eastus2
export MYSQLSUBNETNAME=${MYSQLNAME}Subnet
export MYSQLSUBNETADDRESSPREFIX=10.0.2.0/24
export MYSQLRULENAME=${MYSQLNAME}Rule
#############################################################################################

# Connect to Azure
#az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

# Enable Azure CLI db-up extension (in preview, requires admin)
az extension add --name db-up

echo In addition to creating the server, the az mysql up command creates a sample database, a root user in the database, opens the firewall for Azure services, and creates default firewall rules for the client computer
az mysql up \
 --resource-group $RESOURCEGROUPNAME \
 --server-name $MYSQLNAMEUNIQUE \
 --admin-user $MYSQLUSERNAME \
 --admin-password $MYSQLPASSWORD \
 --backup-retention $MYSQLBACKUPRETAINEDDAYS \
 --database-name $MYSQLDBNAME \
 --geo-redundant-backup $MYSQLGEOREDUNDANTBACKUP \
 --location $REGIONNAME \
 --sku-name $MYSQLSKU \
 --storage-size $MYSQLSTORAGEMBSIZE \
 --version=$MYSQLVERSION

echo Creating and enabling Azure Database for MySQL Virtual Network service endpoints
az network vnet subnet create \
 --resource-group $RESOURCEGROUPNAME \
 --vnet-name $VNETNAME \
 --name $MYSQLSUBNETNAME \
 --service-endpoints Microsoft.SQL \
 --address-prefix $MYSQLSUBNETADDRESSPREFIX

echo Creating a Virtual Network rule on the MySQL server to secure it to the subnet
az mysql server vnet-rule create \
 --resource-group $RESOURCEGROUPNAME \
 --server-name $MYSQLNAMEUNIQUE \
 --vnet-name $VNETNAME \
 --subnet $MYSQLSUBNETNAME \
 --name $MYSQLRULENAME

echo creating a read replica named $MYSQLREADREPLICANAME in the region $MYSQLREADREPLICAREGION using $MYSQLNAMEUNIQUE as a source - master
az mysql server replica create \
 --resource-group $RESOURCEGROUPNAME \
 --name $MYSQLREADREPLICANAME \
 --source-server $MYSQLNAMEUNIQUE \
 --location $MYSQLREADREPLICAREGION
