#!/bin/bash

# CLI Documentation
# ================
# command documentation: https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli#cli-application-create

# Install jq to extract json in bash on mac
# ===============
# brew install jq

# **************** Global variables

# Configurations
export GLOBAL="tenants-config/global/global.json"
export TENANT_A="tenants-config/tenants/tenant-a.json"
export TENANT_B="tenants-config/tenants/tenant-b.json"

# ecommerce application container image names
export REGISTRY_URL=$(cat ./$GLOBAL | jq '.REGISTRY.URL' | sed 's/"//g')
export IMAGE_TAG=$(cat ./$GLOBAL | jq '.REGISTRY.TAG' | sed 's/"//g')
export NAMESPACE=$(cat ./$GLOBAL | jq '.REGISTRY.NAMESPACE' | sed 's/"//g')
export FRONTEND_IMAGE_NAME=$(cat ./$GLOBAL | jq '.IMAGES.NAME_FRONTEND' | sed 's/"//g')
export BACKEND_IMAGE_NAME=$(cat ./$GLOBAL | jq '.IMAGES.NAME_BACKEND' | sed 's/"//g')
export FRONTEND_IMAGE="$REGISTRY_URL.$NAMESPACE.$FRONTEND_IMAGE_NAME:$IMAGE_TAG"
export SERVICE_CATALOG_IMAGE="$REGISTRY_URL.$NAMESPACE.$BACKEND_IMAGE_NAME:$IMAGE_TAG"

# Registry settings
# ibm cloud  container registry settings
export IBMCLOUD_CR_NAMESPACE=$(cat ./$GLOBAL | jq '.REGISTRY.NAMESPACE' | sed 's/"//g')
export IBMCLOUD_CR_REGION_URL=$(cat ./$GLOBAL | jq '.REGISTRY.URL' | sed 's/"//g')
export IBMCLOUD_CR_TAG=$(cat ./$GLOBAL | jq '.REGISTRY.TAG' | sed 's/"//g')

# IBM Cloud target
export RESOURCE_GROUP=$(cat ./$GLOBAL | jq '.IBM_CLOUD.RESOURCE_GROUP' | sed 's/"//g')
export REGION=$(cat ./$GLOBAL | jq '.IBM_CLOUD.REGION' | sed 's/"//g')

# **********************************************************************************
# Functions definition
# **********************************************************************************

function createNamespace(){
     
    echo "IBMCLOUD_CR_NAMESPACE: $IBMCLOUD_CR_NAMESPACE"
    echo "RESOURCE_GROUP       : $RESOURCE_GROUP"
    echo "REGION               : $REGION"
    
    ibmcloud target -g $RESOURCE_GROUP
    ibmcloud target -r $REGION
    ibmcloud cr login
    ibmcloud cr namespace-add $IBMCLOUD_CR_NAMESPACE

}

function createAndPushIBMContainer () {
 
    echo "FRONTEND_IMAGE: $FRONTEND_IMAGE"
    echo "SERVICE_CATALOG_IMAGE: $SERVICE_CATALOG_IMAGE"

    createNamespace
    
    bash ./ce-build-images-ibm-docker.sh $SERVICE_CATALOG_IMAGE \
                                         $FRONTEND_IMAGE
}

# **********************************************************************************
# Execution
# **********************************************************************************

echo "************************************"
echo " Create and push container image to IBM Container Registry"
echo "************************************"

# createAndPushIBMContainer

echo "************************************"
echo " Tenant A"
echo "************************************"

bash ./ce-install-application.sh $GLOBAL $TENANT_A

echo "************************************"
echo " Tenant B"
echo "************************************"

# bash ./ce-install-application.sh $GLOBAL $TENANT_B