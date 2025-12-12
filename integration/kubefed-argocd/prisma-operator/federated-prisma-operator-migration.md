# federated-prisma-operator Migration Guide

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
  repository: docker.artifactory.expedia.biz/runtime/federated-prisma-operator
  tag: latest
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```


## Permission Overrides
```yaml
- name: federated-prisma-operator
  clusterResources:
    - group: apiextensions.k8s.io
      kind: CustomResourceDefinition
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
    - group: admissionregistration.k8s.io
      kind: MutatingWebhookConfiguration
```

## Technical Requirements
- Permission overrides must be merged before deployment
- No region selectors in placement files
- Match deployment suffix to maintain resource identity

## Verification Commands

```bash
# Before migration
kubectl get deployment -n federated-prisma-operator-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > federated-prisma-operator-before.txt

# After migration
kubectl get deployment -n federated-prisma-operator-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > federated-prisma-operator-after.txt

# Compare (timestamps should match)
diff federated-prisma-operator-before.txt federated-prisma-operator-after.txt
```
