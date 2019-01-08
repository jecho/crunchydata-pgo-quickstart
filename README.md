# notes for github.com/CrunchyData/postgres-operator

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

Edit some files for our use case
```
cat > $COROOT/chart/postgres-operator/files/postgres-operator/pgo.yaml <<EOF
Cluster:
  PrimaryNodeLabel:  
  ReplicaNodeLabel: 
  CCPImagePrefix:  crunchydata
  Metrics:  true
  Badger:  true
  CCPImageTag: centos7-10.6-2.2.0 
  Port:  5432
  User:  testuser
  Database:  userdb
  PasswordAgeDays:  60
  PasswordLength:  8
  Strategy:  1
  Replicas:  2
  ArchiveMode:  false
  ArchiveTimeout:  60
  ServiceType:  ClusterIP
  Backrest:  false
  Autofail:  true
  LogStatement:  none
  LogMinDurationStatement:  60000
PrimaryStorage: nfsstorage
BackupStorage: nfsstorage
ReplicaStorage: nfsstorage
Storage:
  hostpathstorage:
    AccessMode:  ReadWriteMany
    Size:  1G
    StorageType:  create
  nfsstorage:
    AccessMode:  ReadWriteOnce
    Size:  1G
    StorageType:  create
    Fsgroup: 0
  storageos:
    AccessMode:  ReadWriteOnce
    Size:  1G
    StorageType:  dynamic
    StorageClass:  fast
    Fsgroup:  26
DefaultContainerResources: 
DefaultLoadResources:  
DefaultLspvcResources:  
DefaultRmdataResources:  
DefaultBackupResources:  
DefaultPgbouncerResources:  
DefaultPgpoolResources:  
ContainerResources:
  small:
    RequestsMemory:  512Mi
    RequestsCPU:  0.1
    LimitsMemory:  512Mi
    LimitsCPU:  0.1
  large:
    RequestsMemory:  2Gi
    RequestsCPU:  2.0
    LimitsMemory:  2Gi
    LimitsCPU:  4.0
Pgo:
  AutofailSleepSeconds:  9
  Audit:  false
  LSPVCTemplate:  /pgo-config/pgo.lspvc-template.json
  LoadTemplate:  /pgo-config/pgo.load-template.json
  COImagePrefix:  crunchydata
  COImageTag:  centos7-3.4.0
EOF

cat > $COROOT/chart/postgres-operator/values.yaml <<EOF
# Default values for postgres-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 1

image:
  repository: crunchydata/postgres-operator
  tag: centos7-3.4.0
  pullPolicy: IfNotPresent

env:
  debug: "true"
  ccp_image_prefix: "crunchydata"
  co_image_prefix: "crunchydata"
  co_image_tag: "centos7-3.4.0"
  tls_no_verify: false

service:
  type: LoadBalancer
  port: 8443

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

serviceAccount:
  name: "postgres-operator"
  create: "true"

rbac:
  create: "true"

nameOverride: "pgo"
EOF
```

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

## Verify client
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
