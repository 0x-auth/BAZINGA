# KubeFed to ArgoCD Migration Integration

This directory contains all files related to the KubeFed to ArgoCD migration for:
- federated-vault-monitoring
- federated-prisma-operator

## Directory Structure

- vault-monitoring/ - Migration files for vault monitoring
- prisma-operator/ - Migration files for prisma operator
- cleanup-results.txt - Results of duplicate script scan
- verify-timestamps.sh - Script to verify deployment timestamps
- continuation-prompt.md - Prompt for continuing conversation in new Claude chat

## Usage

Run verification before deployment:
```bash
./verify-timestamps.sh
```

Run verification after deployment:
```bash
./verify-timestamps.sh after
```

## Generated on: Fri Mar 28 07:38:46 IST 2025
