# postgres-operator-notes, for github.com/CrunchyData/postgres-operator

## Quickstart (quick n dirty)
sets up the helm cluster and all the variables we didn't really want to read about

Source the project
```
cd ~
mkdir -p staging
cd staging
git clone https://github.com/CrunchyData/postgres-operator.git
export COROOT=$HOME/staging/postgres-operator
```

Stand up some useful variables
```
#export COROOT=/Users/jecho/staging/postgres-operator
export CO_IMAGE_PREFIX=crunchydata
export CO_IMAGE_TAG=centos7-3.4.0
```

Install the PGO client
```
```

Install the PGO client
```
export PGO_CA_CERT=$COROOT/conf/postgres-operator/server.crt
export PGO_CLIENT_CERT=$COROOT/conf/postgres-operator/server.crt
export PGO_CLIENT_KEY=$COROOT/conf/postgres-operator/server.key
echo "username:password" > $HOME/.pgouser
```

installs the operator thru helm
```
cd $COROOT/chart
helm install ./postgres-operator
```
extracts external ip and sets our pgo client
```
export CO_APISERVER_NAME=$(kubectl get svc --selector=app=pgo -o=jsonpath="{.items[0].metadata.name}")
export HTTPS=https://
export CO_APISERVER_URL=$(kubectl get svc ${CO_APISERVER_NAME} --output=jsonpath='{range .status.loadBalancer.ingress[0]}{.ip}') 
export CO_APISERVER_PORT=8443
export CO_APISERVER_URL=${HTTPS}${CO_APISERVER_URL}:${CO_APISERVER_PORT}
```

# Verify
pgo version

