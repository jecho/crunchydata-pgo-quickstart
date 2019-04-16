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
git clone https://github.com/CrunchyData/postgres-operator/
git checkout 3.4.0
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
chmod +x pgo-mac
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
```
kubectl patch svc postgres-operator-pgo -p '{"spec": {"type": "LoadBalancer"}}'
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

## Verify Client
```
pgo version
```
>
```
pgo client version 3.4.0
apiserver version 3.4.0
```

## basic commands 
```
pgo create cluster m  # crates primary db instance
pgo create cluster m --pgpool # creates traditinal postgres loadbalancer
pgo create cluster m --replica-count=2 # creates replica
pgo create cluster m --metrics # enables sidecar
pgo create cluster m --replica-count=2 --pgpool --replica-count=2 # aggregated args
pgp delete cluster m
pgo delete cluster m --delete-data --delete-backups
pgo status m
pgp show user m   # shows username and passwords for databases
```

## Integrating into Prometheus 
deploy Prometheus-operator chart and substitute values.yaml at section _additionalScrapeConfigs_
```
additionalScrapeConfigs: 
- job_name: 'default-auto-discovery-postgres'
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - default
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_container_port_number]
    action: keep
    regex: 9\d{3}
  metric_relabel_configs:
  - source_labels: [ __name__ ]
    regex: '(pg_locks_count.*|pg_settings.*|pg_stat_activity.*|pg_stat_bgwriter.*|pg_stat_database.*)'
    action: drop
```
It is purposefully scanning port rage 9000-9999 in default namespace. Still needs to be cleaned up.

## Integrating into Grapha
Manual for now. Using pgmonitors dashboards, but should be integrated into Prometheus operator

https://github.com/CrunchyData/pgmonitor/tree/master/grafana
Pick and choose
