# Set variables for the new AKS cluster
resourceGroup=rg-istio-action
location=westeurope
aksName=aks-istio

# Create AKS cluster
az aks create \
    --resource-group $resourceGroup \
    --name $aksName \
    --node-count 1 \
    --generate-ssh-keys

# Get the credentials for the AKS cluster and merge with kubeconfig
az aks get-credentials --resource-group $resourceGroup --name $aksName
