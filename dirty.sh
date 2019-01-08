cd ~
mkdir -p staging
cd staging
git clone https://github.com/CrunchyData/postgres-operator.git
export COROOT=$HOME/staging/postgres-operator

export CO_IMAGE_PREFIX=crunchydata
export CO_IMAGE_TAG=centos7-3.4.0
Install the pgo client

wget https://github.com/CrunchyData/postgres-operator/releases/download/3.4.0/pgo-mac
chmod +x pgo
mv pgo-mac /usr/local/bin/pgo
Stand up variables for our pgo client

export PGO_CA_CERT=$COROOT/conf/postgres-operator/server.crt
export PGO_CLIENT_CERT=$COROOT/conf/postgres-operator/server.crt
export PGO_CLIENT_KEY=$COROOT/conf/postgres-operator/server.key
echo "username:password" > $HOME/.pgouser

cd $COROOT/chart
helm install ./postgres-operator

export CO_APISERVER_NAME=$(kubectl get svc --selector=app=pgo -o=jsonpath="{.items[0].metadata.name}")
export HTTPS=https://
export CO_APISERVER_URL=$(kubectl get svc ${CO_APISERVER_NAME} --output=jsonpath='{range .status.loadBalancer.ingress[0]}{.ip}') 
export CO_APISERVER_PORT=8443
export CO_APISERVER_URL=${HTTPS}${CO_APISERVER_URL}:${CO_APISERVER_PORT}

