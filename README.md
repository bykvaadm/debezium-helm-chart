# Debezium Helm Chart
forked from https://github.com/bykvaadm/debezium-helm-chart

## Runbook

### setup k8s env
Please follow the guide here to add eks-dev-blue cluster.

### deplyoment
download the codes and run
```
helm upgrade --install debezium-test ./ -f common.yaml -n debezium
```