# federated-vault-monitoring Migration Guide

## Files

### Placement File
```yaml
clusterSelector:
  matchExpressions:
    - { key: k8s.expediagroup.com/environment-tier, operator: In, values: [ test ] }
    - { key: k8s.expediagroup.com/island, operator: In, values: [ data ] }
    - { key: k8s.expediagroup.com/pci-category, operator: In, values: [ oos ] }
```

### Values File
```yaml
replicaCount: 2
image:
  repository: docker.artifactory.expedia.biz/runtime/federated-vault-monitoring
  tag: latest
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```



## Technical Requirements
- 
- No region selectors in placement files
- Match deployment suffix to maintain resource identity

## Verification Commands

```bash
# Before migration
kubectl get deployment -n federated-vault-monitoring-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > federated-vault-monitoring-before.txt

# After migration
kubectl get deployment -n federated-vault-monitoring-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > federated-vault-monitoring-after.txt

# Compare (timestamps should match)
diff federated-vault-monitoring-before.txt federated-vault-monitoring-after.txt
```
