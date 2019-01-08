# notes for github.com/CrunchyData/postgres-operator

## Quickstart (quick n dirty)
```
git clone https://github.com/jecho/postgres-operator-notes.git
cd postgres-operator-notes
./dirty.sh
```

## Manual Quickstart
sets up the helm cluster and all the variables we didn't really want to read about

Source the project
```
cd ~
mkdir -p staging
cd staging
git clone https://github.com/jecho/postgres-operator-notes
export COROOT=$HOME/staging/postgres-operator
```

Stand up some useful variables
```
#export COROOT=/Users/jecho/staging/postgres-operator
export CO_IMAGE_PREFIX=crunchydata
export CO_IMAGE_TAG=centos7-3.4.0
```

Edit some files for our use case
run changes.sh

Installs the Operator thru Helm
```
cd $COROOT/chart
helm install ./postgres-operator
```

Install the pgo client
```
wget https://github.com/CrunchyData/postgres-operator/releases/download/3.4.0/pgo-mac
chmod +x pgo
mv pgo-mac /usr/local/bin/pgo
```

Stand up variables for our pgo client
```
export PGO_CA_CERT=$COROOT/conf/postgres-operator/server.crt
export PGO_CLIENT_CERT=$COROOT/conf/postgres-operator/server.crt
export PGO_CLIENT_KEY=$COROOT/conf/postgres-operator/server.key
echo "username:password" > $HOME/.pgouser
```

## Setup PGO Client
we have to wait until the provider declares an external ip to map

extracts external ip and sets our pgo client
```
export CO_APISERVER_NAME=$(kubectl get svc --selector=app=pgo -o=jsonpath="{.items[0].metadata.name}")
export HTTPS=https://
export CO_APISERVER_URL=$(kubectl get svc ${CO_APISERVER_NAME} --output=jsonpath='{range .status.loadBalancer.ingress[0]}{.ip}') 
export CO_APISERVER_PORT=8443
export CO_APISERVER_URL=${HTTPS}${CO_APISERVER_URL}:${CO_APISERVER_PORT}
```
## Verify Operator 
```
kubectl get deploy --selector=app=pgo
```
>
```
NAME                                      READY   STATUS    RESTARTS   AGE
invisible-elephant-pgo-768789d55c-b8f68   2/2     Running   0          38m
```

## Verify Client
```
pgo version
```
>
```
pgo client version 3.4.0
apiserver version 3.4.0
```

## Deploy some things
that stuff will go here
