#!/bin/bash

sudo apt-get update

# Injecting environment variables
echo '#!/bin/bash' >> vars.sh
echo $adminUsername:$1 | awk '{print substr($1,2); }' >> vars.sh
echo $adminPasswordOrKey:$2 | awk '{print substr($1,2); }' >> vars.sh
echo $appId:$3 | awk '{print substr($1,2); }' >> vars.sh
echo $password:$4 | awk '{print substr($1,2); }' >> vars.sh
echo $tenantId:$5 | awk '{print substr($1,2); }' >> vars.sh
echo $vmName:$6 | awk '{print substr($1,2); }' >> vars.sh
sed -i '2s/^/export adminUsername=/' vars.sh
sed -i '3s/^/export adminPasswordOrKey=/' vars.sh
sed -i '4s/^/export appId=/' vars.sh
sed -i '5s/^/export password=/' vars.sh
sed -i '6s/^/export tenantId=/' vars.sh
sed -i '7s/^/export vmName=/' vars.sh

chmod +x vars.sh 
. ./vars.sh

publicIp=$(curl icanhazip.com)

# Installing Rancher K3s single master cluster using k3sup
sudo -u $adminUsername mkdir /home/${adminUsername}/.kube
curl -sLS https://get.k3sup.dev | sh
sudo cp k3sup /usr/local/bin/k3sup
sudo k3sup install --local --context arck3sdemo --ip $publicIp
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cp kubeconfig /home/${adminUsername}/.kube/config
chown -R $adminUsername /home/${adminUsername}/.kube/

# Installing Helm 3
sudo snap install helm --classic

# Set up Managed Identity
TENANT_ID=$5
SUBSCRIPTION_ID=$7
RESOURCE_GROUP=$8

sudo rm -rf "/etc/kubernetes/azure.json"
sudo mkdir -p "/etc/kubernetes/"

echo "{
  \"cloud\": \"AzurePublicCloud\",
  \"tenantId\": \"$TENANT_ID\",
  \"subscriptionId\": \"$SUBSCRIPTION_ID\",
  \"resourceGroup\": \"$RESOURCE_GROUP\",
  \"useManagedIdentityExtension\": true
}" | sudo tee /etc/kubernetes/azure.json
