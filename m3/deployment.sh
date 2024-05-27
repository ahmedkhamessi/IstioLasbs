# deploy the catalog service version 2
kubectl apply -f m1/application/catalog/kubernetes/catalog-deployment-v2.yaml

#deploy the catalog destination rule
kubectl apply -f m1/config/catalog-destinationrule.yaml

# update the virtual service to route traffic to the new version of the catalog service based on headers
kubectl apply -f m1/config/catalog-virtualservice-dark-v2.yaml

# test the new version of the catalog service
curl http://$EXTERNAL_IP/api/catalog -H "x-dark-launch: v2"

# clean up
kubectl delete deployment,svc,gateway,\
virtualservice,destinationrule --all -n istioinaction