# Deploy the catalog service
istioctl kube-inject -f services/catalog/kubernetes/catalog.yaml

# enable automatic sidecar injection
kubectl label namespace istioinaction istio-injection=enabled

# Test the catalog service internally
 kubectl run -i -n default --rm --restart=Never dummy \
--image=curlimages/curl --command -- \
sh -c 'curl -s http://catalog.istioinaction/items/1'

# Deploy the web service
kubectl apply -f services/webapp/kubernetes/webapp.yaml

# Test the web service internally
kubectl run -i -n default --rm --restart=Never dummy \
--image=curlimages/curl --command -- \
sh -c 'curl -s http://webapp.istioinaction/api/catalog/items/1'

# Configure the ingress gateway to expose the web service
kubectl apply -f ch2/ingress-gateway.yaml

# Test the web service externally
## Get the external IP address of the ingress gateway
EXTERNAL_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "External IP: $EXTERNAL_IP"

curl http://$EXTERNAL_IP/api/catalog/items/1


## Monitoring
# Expose Grafana
./m1/expose-grafana.sh
# check the metrics under grafana/dashboards/istio-service-dashboard
# generate traffic to the web service internally
kubectl run -i -n default --rm --restart=Never dummy \
--image=curlimages/curl --command -- \
sh -c 'while true; do curl -s http://webapp.istioinaction/api/catalog/items/1; sleep 5; done'

# Expose Jaeger
./m1/expose-opentracing.sh
# generate traffic to the web service internally
while true; do curl http://20.31.19.37/api/catalog; sleep .5; done
