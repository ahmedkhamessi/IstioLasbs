kubectl config set-context $(kubectl config current-context) \
 --namespace=istioinaction


# Configure an ingress gateway for the application
kubectl apply -f coolstore-gw.yaml

# check if envoy is configure to listen on port 80
##istioctl -n istio-system proxy-config listener deploy/istio-ingressgateway
kubectl describe endpoints istio-ingressgateway -n istio-system

# deploy the virtual service
kubectl apply -f coolstore-vs.yaml

# deploy the services
# kubectl apply -f services/catalog/kubernetes/catalog.yaml
kubectl apply -f catalog.yaml
kubectl apply -f webapp.yaml

# get the external IP of the istio-ingressgateway
URL=$(kubectl -n istio-system get svc istio-ingressgateway \
-o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# test the ingress gateway by accessing the URL
curl -v http://$URL/api/catalog

# specify the host header in the request
curl -v -H "Host: webapp.istioinaction.io" http://$URL/api/catalog

## Comfigure TLS for the ingress gateway
# create a secret for the certificate
kubectl create -n istio-system secret tls webapp-credential \
--key certs/3_application/private/webapp.istioinaction.io.key.pem \
--cert certs/3_application/certs/webapp.istioinaction.io.cert.pem

# configure the gateway for HTTPS and open port 443
kubectl apply -f coolstore-gw-tls.yaml

# Test the ingress gateway with HTTPS
curl -v -H "Host: webapp.istioinaction.io" https://$URL/api/catalog
# --> fails because the server cannot be verified using the default CA certificate chains

# Test the ingress gateway with HTTPS and the self-signed certificate
curl -v -H "Host: webapp.istioinaction.io" \
    --cacert certs/3_application/certs/ca-cert.pem \
    https://$URL/api/catalog
# -> fails because the server certificate is issued for webapp.istioinaction.io, and we’re calling

# Test the ingress gateway with HTTPS by adding a resolver for the host
curl -v -H "Host: webapp.istioinaction.io" \
    --resolve webapp.istioinaction.io:443:$URL \
    --cacert certs/2_intermediate/certs/ca-chain.cert.pem \
    https://webapp.istioinaction.io/api/catalog


## HTTP redirect to HTTPS
# configure the gateway to redirect HTTP to HTTPS
kubectl apply -f coolstore-gw-tls-redirect.yaml

# Test the ingress gateway with HTTP
curl -v http://$URL/api/catalog \
  -H "Host: webapp.istioinaction.io"

## Configure mutual TLS for the ingress gateway
# create a secret for the client certificate
kubectl create -n istio-system secret \
generic webapp-credential-mtls --from-file=tls.key=\
ch4/certs/3_application/private/webapp.istioinaction.io.key.pem \
--from-file=tls.crt=\
ch4/certs/3_application/certs/webapp.istioinaction.io.cert.pem \
--from-file=ca.crt=ch4/certs/2_intermediate/certs/ca-chain.cert.pem

# configure the gateway for mutual TLS
kubectl apply -f coolstore-gw-mtls.yaml

# Test the ingress gateway assuming simple TLS
curl -v -H "Host: webapp.istioinaction.io" \
    --resolve webapp.istioinaction.io:443:$URL \
    --cacert certs/2_intermediate/certs/ca-chain.cert.pem \
    https://webapp.istioinaction.io/api/catalog

# -> fails because the server requires a client certificate

# delete the pod to force the sidecar to restart and pick up the new configuration
kubectl delete po -n istio-system -l app=istio-ingressgateway

# Test the ingress gateway with mutual TLS
curl -H "Host: webapp.istioinaction.io" \
https://webapp.istioinaction.io:443/api/catalog \
--cacert ch4/certs/2_intermediate/certs/ca-chain.cert.pem \
--resolve webapp.istioinaction.io:443:$URL \
--cert ch4/certs/4_client/certs/webapp.istioinaction.io.cert.pem \
--key ch4/certs/4_client/private/webapp.istioinaction.io.key.pem

