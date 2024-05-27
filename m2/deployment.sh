# add fault behavior to the web service (return 500 error code with 100% probability)
./chaos.sh 500 100

# add fault behavior to the web service (return 500 error code with 50% probability)
./chaos.sh 500 50

# configure the virtual service to add retries up to 3 times with a 2 second delay
kubectl apply -f m1/config/catalog-virtualservice.yaml

# stop the fault behavior
./chaos.sh 500 delete