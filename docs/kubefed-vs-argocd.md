# KubeFed vs ArgoCD: Understanding Your Migration

## KubeFed (Kubernetes Federation)

KubeFed is a Kubernetes tool designed to coordinate the configuration of multiple Kubernetes clusters.

### Key Capabilities

- **Multi-cluster resource management**: Define workloads that span multiple clusters
- **Workload distribution**: Spread applications across clusters based on policies
- **Resource propagation**: Define a resource once and propagate it to selected clusters
- **Regional isolation**: Deploy the same configuration to different regions
- **Cross-cluster service discovery**: Enable services to find each other across clusters

### KubeFed Components

```
┌───────────────────────┐
│                       │
│  Federation Control   │
│       Plane          │
│                       │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│                       │
│   Federated API       │
│                       │
└─────┬─────┬─────┬─────┘
      │     │     │
      ▼     ▼     ▼
┌─────┐ ┌─────┐ ┌─────┐
│ K8s │ │ K8s │ │ K8s │
│ #1  │ │ #2  │ │ #3  │
└─────┘ └─────┘ └─────┘
```

### Limitations

- Reaching end-of-life (EOL) in Q2 2025
- Complex propagation model
- Limited GitOps integration
- Challenging to debug across clusters

## ArgoCD

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes applications.

### Key Capabilities

- **GitOps workflow**: Git repositories as the source of truth
- **Automated deployment**: Continuous monitoring of Git repos and automatic updates
- **Application synchronization**: Ensure deployed state matches desired state
- **Multi-cluster deployment**: Deploy to multiple clusters from one ArgoCD instance
- **Rich visualization**: Web UI to observe application and cluster state
- **Rollback & history**: Easy rollback to previous application versions

### ArgoCD Architecture

```
┌───────────────────────┐     ┌───────────────────────┐
│                       │     │                       │
│    Git Repository     │────▶│      ArgoCD Server    │
│                       │     │                       │
└───────────────────────┘     └───────────┬───────────┘
                                          │
                                          ▼
                              ┌───────────────────────┐
                              │                       │
                              │   Application         │
                              │   Controller          │
                              │                       │
                              └─────┬─────┬─────┬─────┘
                                    │     │     │
                                    ▼     ▼     ▼
                              ┌─────┐ ┌─────┐ ┌─────┐
                              │ K8s │ │ K8s │ │ K8s │
                              │ #1  │ │ #2  │ │ #3  │
                              └─────┘ └─────┘ └─────┘
```

## Migration: From KubeFed to ArgoCD

### Key Differences

| Aspect | KubeFed | ArgoCD |
|--------|---------|--------|
| Configuration Source | Federation API | Git Repository |
| Deployment Method | Manual propagation | Continuous sync |
| Multi-cluster Strategy | Resource federation | Application deployment |
| Configuration | KubeFed manifests | Values and placement files |
| Region Selection | In manifest files | In UI (Spinnaker) |
| Update Mechanism | Update federated resources | Commit to Git |

### Migration Steps Overview

1. Replace KubeFed manifests with:
   - Placement files (cluster selection)
   - Values files (application configuration)

2. Update deployment pipelines:
   - Remove KubeFed deployment stages
   - Add RCP Plugin Deployment stages
   - Select regions in Spinnaker UI (not in placement files)

3. Create ArgoCD catalog entries to register applications

4. Validate deployments maintain same deployment timestamps

## Critical Migration Considerations

1. **Region selection**: NEVER include region selectors in placement files; use Spinnaker dropdown instead

2. **Deployment suffixes**: Use EXACT same suffixes as current deployment to preserve resources 

3. **Permission requirements**: Some applications (like federated-prisma-operator) need additional permissions that must be set up BEFORE deployment

4. **Resource specifications**: Keep identical resource limits/requests to avoid recreation

5. **Validation**: Compare deployment timestamps before and after migration to confirm no recreation occurred

## Timeline

- **KubeFed EOL**: Q2 2025 (April 30, 2025)
- **Migration Deadline**: Before April 30, 2025
- **Current Status**: OVERDUE

## Support Resources

- **Help Channel**: #rcp-contributors Slack channel
- **Reference Implementation**: federated-spark-operator (completed January 2025)
