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
