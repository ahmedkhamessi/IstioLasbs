docker pull envoyproxy/envoy:v1.19.0
docker pull curlimages/curl
docker pull citizenstig/httpbin

# set up the httpbin service
docker run -d --name httpbin citizenstig/httpbin

# Test the httpbin service
docker run -it --rm --link httpbin curlimages/curl \
curl -X GET http://httpbin:8000/headers

# set up the Envoy proxy
docker run -it --rm envoyproxy/envoy:v1.19.0 envoy --config-yaml "$(cat simple.yaml)"

# Test the Envoy proxy
docker run -it --rm --link proxy curlimages/curl \
   curl  -X GET http://proxy:15001/headers

# Check the result
# X-Envoy-Expected-Rq-Timeout-Ms": "15000",
# "X-Request-Id": "45f74d49-7933-4077-b315-c15183d1da90"

# Check the Envoy Admin API

# Access the metrics endpoint
docker run -it --rm --link proxy curlimages/curl \
   curl  -X GET http://proxy:15000/stats