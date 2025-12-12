#!/bin/bash
# BAZINGA Migration Integration Script
# Integrates KubeFed-to-ArgoCD migration with BAZINGA system
# Save as ~/AmsyPycharm/BAZINGA/bin/bazinga-migration-integrator.sh

# Set variables
BAZINGA_ROOT=~/AmsyPycharm/BAZINGA
DOCS_DIR=$BAZINGA_ROOT/docs
ARTIFACTS_DIR=$BAZINGA_ROOT/artifacts/claude_artifacts
SCRIPTS_DIR=$BAZINGA_ROOT/scripts
BIN_DIR=$BAZINGA_ROOT/bin
MIGRATION_DIR=$BAZINGA_ROOT/integration/kubefed-argocd

# Create directories
mkdir -p $MIGRATION_DIR/vault-monitoring
mkdir -p $MIGRATION_DIR/prisma-operator
mkdir -p $ARTIFACTS_DIR/migration

# Help function
show_help() {
  echo "BAZINGA Migration Integrator"
  echo ""
  echo "Usage: bazinga-migration-integrator.sh [command]"
  echo ""
  echo "Commands:"
  echo "  extract       - Extract migration artifacts from conversation"
  echo "  generate      - Generate documentation for both applications"
  echo "  cleanup       - Clean up redundant files"
  echo "  continue      - Generate continuation prompt"
  echo "  verify        - Run kubectl verification commands"
  echo "  integrate     - Integrate all migration components"
  echo "  help          - Show this help"
  echo ""
}

# Extract artifacts from conversation
extract_artifacts() {
  echo "Extracting migration artifacts..."
  
  # Copy artifacts to migration directory
  if [ -f "$ARTIFACTS_DIR/vault-monitoring-final-tasks.md" ]; then
    cp "$ARTIFACTS_DIR/vault-monitoring-final-tasks.md" "$MIGRATION_DIR/vault-monitoring/"
  fi
  
  if [ -f "$ARTIFACTS_DIR/prisma-operator-final-tasks.md" ]; then
    cp "$ARTIFACTS_DIR/prisma-operator-final-tasks.md" "$MIGRATION_DIR/prisma-operator/"
  fi
  
  if [ -f "$ARTIFACTS_DIR/pr-response-for-prisma-reviewers.md" ]; then
    cp "$ARTIFACTS_DIR/pr-response-for-prisma-reviewers.md" "$MIGRATION_DIR/prisma-operator/"
  fi
  
  # Create index file
  cat > "$MIGRATION_DIR/index.md" << EOF
# KubeFed to ArgoCD Migration

## Applications
- [Vault Monitoring](./vault-monitoring/vault-monitoring-final-tasks.md)
- [Prisma Operator](./prisma-operator/prisma-operator-final-tasks.md)

## Documentation
- [PR Response](./prisma-operator/pr-response-for-prisma-reviewers.md)
- [System Analysis](./system-analysis.md)

## Generated on: $(date)
EOF

  echo "Artifacts extracted to $MIGRATION_DIR"
}

# Generate documentation
generate_docs() {
  echo "Generating migration documentation..."
  
  # Create migration doc generator if not exists
  if [ ! -f "$SCRIPTS_DIR/migration-doc-generator.sh" ]; then
    cat > "$SCRIPTS_DIR/migration-doc-generator.sh" << 'EOF'
#!/bin/bash
# Migration documentation generator
# Usage: ./migration-doc-generator.sh [app_name] [permission_required]

APP_NAME=${1:-"federated-vault-monitoring"}
PERMISSION_REQUIRED=${2:-"false"}
OUTPUT_DIR=~/AmsyPycharm/BAZINGA/docs

mkdir -p "$OUTPUT_DIR"

cat > "$OUTPUT_DIR/$APP_NAME-migration.md" << EOD
# $APP_NAME Migration Guide

## Files

### Placement File
\`\`\`yaml
clusterSelector:
  matchExpressions:
    - { key: k8s.expediagroup.com/environment-tier, operator: In, values: [ test ] }
    - { key: k8s.expediagroup.com/island, operator: In, values: [ data ] }
    - { key: k8s.expediagroup.com/pci-category, operator: In, values: [ oos ] }
\`\`\`

### Values File
\`\`\`yaml
replicaCount: 2
image:
  repository: docker.artifactory.expedia.biz/runtime/$APP_NAME
  tag: latest
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
\`\`\`

$([ "$PERMISSION_REQUIRED" == "true" ] && echo '
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
')

## Technical Requirements
- $([ "$PERMISSION_REQUIRED" == "true" ] && echo "Permission overrides must be merged before deployment")
- No region selectors in placement files
- Match deployment suffix to maintain resource identity

## Verification Commands

\`\`\`bash
# Before migration
kubectl get deployment -n $APP_NAME-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > $APP_NAME-before.txt

# After migration
kubectl get deployment -n $APP_NAME-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > $APP_NAME-after.txt

# Compare (timestamps should match)
diff $APP_NAME-before.txt $APP_NAME-after.txt
\`\`\`
EOD

echo "Documentation created at $OUTPUT_DIR/$APP_NAME-migration.md"
EOF

    chmod +x "$SCRIPTS_DIR/migration-doc-generator.sh"
  fi
  
  # Generate docs
  "$SCRIPTS_DIR/migration-doc-generator.sh" "federated-vault-monitoring" "false"
  "$SCRIPTS_DIR/migration-doc-generator.sh" "federated-prisma-operator" "true"
  
  # Copy to migration directory
  cp "$DOCS_DIR/federated-vault-monitoring-migration.md" "$MIGRATION_DIR/vault-monitoring/"
  cp "$DOCS_DIR/federated-prisma-operator-migration.md" "$MIGRATION_DIR/prisma-operator/"
  
  echo "Documentation generated"
}

# Clean up redundant files
cleanup_files() {
  echo "Cleaning up redundant files..."
  
  # Create cleanup script to find duplicates
  cat > "$MIGRATION_DIR/cleanup.sh" << 'EOF'
#!/bin/bash
# Find duplicate scripts
find ~/AmsyPycharm/BAZINGA/scripts ~/AmsyPycharm/BAZINGA/bin -type f -name "*.sh" | sort > /tmp/all_scripts.txt
cat /tmp/all_scripts.txt | xargs md5 | sort | awk '{print $1}' | uniq -d > /tmp/duplicate_hashes.txt

if [ -s /tmp/duplicate_hashes.txt ]; then
  echo "Potential duplicate scripts found:"
  for hash in $(cat /tmp/duplicate_hashes.txt); do
    echo "Duplicate group with hash $hash:"
    cat /tmp/all_scripts.txt | xargs md5 | grep $hash | awk '{print $4}'
    echo ""
  done
else
  echo "No duplicate scripts found."
fi

# Find broken symlinks
echo -e "\n==== Finding Broken Symlinks ===="
find ~/AmsyPycharm/BAZINGA -type l -exec test ! -e {} \; -print
EOF

  chmod +x "$MIGRATION_DIR/cleanup.sh"
  
  # Run cleanup script
  "$MIGRATION_DIR/cleanup.sh" > "$MIGRATION_DIR/cleanup-results.txt"
  
  echo "Cleanup results saved to $MIGRATION_DIR/cleanup-results.txt"
}

# Generate continuation prompt
generate_continuation() {
  echo "Generating continuation prompt..."
  
  # Create generator script if not exists
  if [ ! -f "$SCRIPTS_DIR/generate-continuation-prompt.sh" ]; then
    cat > "$SCRIPTS_DIR/generate-continuation-prompt.sh" << 'EOF'
#!/bin/bash
# BAZINGA Conversation State Continuation Generator

# Output file
OUTPUT_FILE=~/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/continuation-prompt.md

# Extract key information from existing artifacts
VAULT_TASKS=$(cat ~/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/vault-monitoring-final-tasks.md 2>/dev/null || echo "Artifact not found")
PRISMA_TASKS=$(cat ~/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/prisma-operator-final-tasks.md 2>/dev/null || echo "Artifact not found")
SYSTEM_ANALYSIS=$(cat ~/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/system-analysis.md 2>/dev/null || echo "Artifact not found")

# Create directory if it doesn't exist
mkdir -p ~/AmsyPycharm/BAZINGA/artifacts/claude_artifacts/

# Generate the continuation prompt
cat > "$OUTPUT_FILE" << EOF
# BAZINGA Conversation State Continuation

This is a continuation of our conversation about KubeFed to ArgoCD migration and the BAZINGA system architecture. We need to maintain the state and context of our previous discussion.

## Current Conversation State

1. **KubeFed to ArgoCD Migration Status**:
   - federated-vault-monitoring: Application PR and ArgoCD Catalog PR (#441) created, pending kubectl verification and Spinnaker updates
   - federated-prisma-operator: Application PR #83 created, needs permission overrides PR, ArgoCD catalog PR, and Spinnaker updates
   - PR reviewers asked about replicaCount and tag settings in values.yaml

2. **BAZINGA System Context**:
   - Over 6,880 source files identified in ~/AmsyPycharm/BAZINGA
   - Key scripts for migration identified in scripts/ and bin/ directories
   - Migration doc generator created to automate documentation
   - Cleanup tools to identify redundant files and symlinks

3. **Core Migration Patterns**:
   - Remove region selectors from placement files
   - Keep 'replicaCount: 2' for high availability (not testing)
   - Change 'tag: latest' to specific version tags
   - Create permission overrides for CRDs and webhooks (for prisma-operator)
   - Match deployment suffix for resource continuity
   - Use kubectl timestamp verification to prevent recreation

## Vault Monitoring Tasks

\\\`\\\`\\\`
\${VAULT_TASKS}
\\\`\\\`\\\`

## Prisma Operator Tasks

\\\`\\\`\\\`
\${PRISMA_TASKS}
\\\`\\\`\\\`

## System Analysis

\\\`\\\`\\\`
\${SYSTEM_ANALYSIS}
\\\`\\\`\\\`

## Migration Scripts

1. **Documentation Generation**
   - ~/AmsyPycharm/BAZINGA/scripts/generate-ssri-docs.sh
   - ~/AmsyPycharm/BAZINGA/bin/bazinga-insight-extractor.sh
   - ~/AmsyPycharm/BAZINGA/scripts/extract-claude-artifacts.sh

2. **System Cleanup**
   - ~/AmsyPycharm/BAZINGA/scripts/system-cleanup-script.sh
   - ~/AmsyPycharm/BAZINGA/scripts/script-finder.sh
   - ~/AmsyPycharm/BAZINGA/scripts/fix_circular_symlinks.sh

3. **Analysis Tools**
   - ~/AmsyPycharm/BAZINGA/scripts/project-analyzer.sh
   - ~/AmsyPycharm/BAZINGA/scripts/workspace-analyser.sh
   - ~/AmsyPycharm/BAZINGA/bin/bazinga-script-navigator.sh

## Next Steps

1. Complete the migration-doc-generator.sh implementation
2. Execute missing kubectl commands for timestamp verification
3. Create permission overrides PR for prisma-operator
4. Update Spinnaker pipelines for both applications
5. Extend BAZINGA system to support future migrations

Please treat this as a direct continuation of our previous conversation, maintaining all context, depth, and nuance. We were exploring how the migration process reflects deeper patterns of system evolution while maintaining trust and identity continuity.
EOF

echo "Continuation prompt generated: $OUTPUT_FILE"
echo "Run 'cat $OUTPUT_FILE' to view the prompt"
echo "Copy and paste the content into a new Claude chat to continue the conversation"
echo "Updated with information from existing artifacts"
EOF

    chmod +x "$SCRIPTS_DIR/generate-continuation-prompt.sh"
  fi
  
  # Run generator
  "$SCRIPTS_DIR/generate-continuation-prompt.sh"
  
  # Copy to migration directory
  cp "$ARTIFACTS_DIR/continuation-prompt.md" "$MIGRATION_DIR/"
  
  echo "Continuation prompt generated at $ARTIFACTS_DIR/continuation-prompt.md"
  echo "Also copied to $MIGRATION_DIR/continuation-prompt.md"
}

# Run kubectl verification
run_verification() {
  echo "Running kubectl verification commands..."
  
  # Create verification script
  cat > "$MIGRATION_DIR/verify-timestamps.sh" << 'EOF'
#!/bin/bash
# Verify deployment timestamps for KubeFed to ArgoCD migration

# Vault Monitoring
echo "Checking federated-vault-monitoring timestamps..."
kubectl get deployment -n federated-vault-monitoring-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > vault-before.txt
echo "Timestamps saved to vault-before.txt"

# Prisma Operator
echo "Checking federated-prisma-operator timestamps..."
kubectl get deployment -n federated-prisma-operator-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > prisma-before.txt
echo "Timestamps saved to prisma-before.txt"

echo "After running Spinnaker pipelines, run this again with the 'after' argument to verify timestamps weren't changed."
echo "Example: ./verify-timestamps.sh after"

if [ "$1" == "after" ]; then
  # Get after timestamps
  kubectl get deployment -n federated-vault-monitoring-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > vault-after.txt
  kubectl get deployment -n federated-prisma-operator-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > prisma-after.txt
  
  # Compare
  echo "Comparing vault timestamps..."
  diff vault-before.txt vault-after.txt
  
  echo "Comparing prisma timestamps..."
  diff prisma-before.txt prisma-after.txt
  
  if [ $? -eq 0 ]; then
    echo "Success! Timestamps match, resources were not recreated."
  else
    echo "Warning! Timestamps changed, resources were recreated."
  fi
fi
EOF

  chmod +x "$MIGRATION_DIR/verify-timestamps.sh"
  
  echo "Verification script created at $MIGRATION_DIR/verify-timestamps.sh"
  echo "Run this script before and after running Spinnaker pipelines"
}

# Integrate all components
integrate_components() {
  echo "Integrating all migration components..."
  
  # Extract artifacts
  extract_artifacts
  
  # Generate documentation
  generate_docs
  
  # Clean up redundant files
  cleanup_files
  
  # Generate continuation prompt
  generate_continuation
  
  # Run verification
  run_verification
  
  # Create symbolic links to main script
  ln -sf "$BIN_DIR/bazinga-migration-integrator.sh" "$BAZINGA_ROOT/bazinga-kubefed-argocd.sh"
  
  # Create README
  cat > "$MIGRATION_DIR/README.md" << EOF
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
\`\`\`bash
./verify-timestamps.sh
\`\`\`

Run verification after deployment:
\`\`\`bash
./verify-timestamps.sh after
\`\`\`

## Generated on: $(date)
EOF

  echo "Integration complete!"
  echo "All migration components have been integrated into $MIGRATION_DIR"
}

# Main execution
case "$1" in
  extract)
    extract_artifacts
    ;;
  generate)
    generate_docs
    ;;
  cleanup)
    cleanup_files
    ;;
  continue)
    generate_continuation
    ;;
  verify)
    run_verification
    ;;
  integrate)
    integrate_components
    ;;
  help|*)
    show_help
    ;;
esac

# Add to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "export PATH=\"\$PATH:$BIN_DIR\"" >> ~/.bashrc
  echo "Added $BIN_DIR to PATH"
fi

exit 0
