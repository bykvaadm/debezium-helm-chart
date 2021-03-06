# Debezium helm chart by citymobil team

## What this chart is capable of

This chart is designed to create debezium instances in k8s cluster. Tested on version 1.19.4.

### Features

1) On the startup there is an init container that connects to kafka and creates all necessary topics (5 system and one
   topic for each table). If topic exists, it does nothing. Container can't change parameters of an already created
   topic.

2) On the startup there is an init container that downloads jar file to serve prometheus metrics

3) On the startup of main container we always send PUT request to local debezium and this approach makes possible to
   update connectors parameters on helm upgrade - no need to do it by hands.

### Restrictions

1) For the sake of simplicity this chart supposes that u have only ONE connector per chart setup. That is it - one
   config, one database, multiple tables. This division was made b'case it's greatly separates many highloaded tables
   and makes possible to have minimal downtime for connector without affecting other tables.

2) Liveness Probe is not ideal for now. Connector can stuck, and the only fact it doesn't work - that jmx stops serving
   debezium metrics. We r still working on this and u MUST connect monitoring system to get notified about problems with
   connector.

## Installation

First, u SHOUD change all necessary parameters such as kafka servers, include tables, database login and password and so
on. We have a repository, where we store N connector_name.yaml helm value files (1 file = 1 helm installation = 1
connector). Mainly those files include debezium.{env,connector,resources} values. Chart is designed to merge
debezium.env values, so u can include really few of them in every connector as well as put values that don't change in
common.yaml and setup helm as `helm install -f common.yaml -f connector_name.yaml`

So u can use something like this to install chart:

```bash
helm upgrade --install debezium-NAME /path/to/debezium/chart -f common.yaml -f CONNECTOR_NAME.yaml --namespace debezium
```

### Topic naming convention

For every connector, even it serves only one table we should crate 5 system tables. So we r using this approach: imagine
u have database with name DB and table with name TABLE. So u can name all necessary topics in config as so:

```bash
debezium.DB.TABLE
debezium.DB.TABLE.configs
debezium.DB.TABLE.history
debezium.DB.TABLE.offsets
debezium.DB.TABLE.schema
debezium.DB.TABLE.statuses
```

WHY? Look at example above. It's simple, straight and clear. We use debezium config transformations - so each look at
any kafka topic exactly identifies what this topic is about and what connector belongs to.

### CI/CD (gitlab)

We're using an experimental helm feature to push and pull chart to OCI registry.

#### Chart push

```yaml
deploy_helm:
  stage: deploy
  image: docker:18-dind
  services:
  - docker:18-dind
  environment: { name: production }
  tags: [docker]
  only:
    refs: [master]
  script:
  - export CHART_VERSION=$(grep version Chart.yaml | awk '{print $2}')
  - chmod 400 $DOCKERCONFIG
  - mkdir registry
  - alias helm='docker run -v $(pwd)/regisry:/root/.cache/helm/registry -v $(pwd):/apps -v ${DOCKERCONFIG}:/root/.docker/config.json -e DOCKER_CONFIG="/root/.docker" -e HELM_REGISTRY_CONFIG="/root/.docker/config.json" -e HELM_EXPERIMENTAL_OCI=1 alpine/helm'
  - helm chart save . registry.company.com/helm/charts/debezium:${CHART_VERSION}
  - helm chart push registry.company.com/helm/charts/debezium:${CHART_VERSION}
```

#### Chart installation

```yaml
  script:
  - chmod 400 $DOCKERCONFIG
  - chmod 400 $KUBECONFIG
  - mkdir registry
  - alias helm='docker run -v ${KUBECONFIG}:/root/.kube/config -v $(pwd)/regisry:/root/.cache/helm/registry -v $(pwd):/apps -v ${DOCKERCONFIG}:/root/.docker/config.json -e DOCKER_CONFIG="/root/.docker" -e HELM_REGISTRY_CONFIG="/root/.docker/config.json" -e HELM_EXPERIMENTAL_OCI=1 alpine/helm'
  - helm chart pull company.com/helm/charts/debezium:$chart_version
  - helm chart export rcompany.com/helm/charts/debezium:$chart_version
  - helm upgrade --install -f ....... 
```

## Monitoring

We have a grafana dashboard (much more normal than official which was lat updated 2 years ago), but it is still not ready
for production. As soon it will be ready we will publish it on grafana.com and put link here.
