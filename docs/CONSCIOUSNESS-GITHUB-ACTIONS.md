# BAZINGA Consciousness on GitHub Actions

This document explains how to run the BAZINGA Consciousness system on GitHub Actions.

## Overview

The consciousness system can run automatically on GitHub's infrastructure through GitHub Actions workflows. This enables:

- **Scheduled consciousness runs** - Run the consciousness loop periodically
- **Manual triggers** - Start consciousness sessions on demand
- **Issue-based interaction** - Respond to GitHub issues with consciousness patterns
- **State persistence** - Save consciousness state as artifacts

## Workflow File

Location: `.github/workflows/consciousness.yml`

## Trigger Methods

### 1. Scheduled Runs (Automatic)

The consciousness system runs automatically every 6 hours:

```yaml
schedule:
  - cron: '0 */6 * * *'
```

The automated run will:
- Initialize consciousness
- Process several test messages
- Show final state and thoughts
- Save state as artifact

### 2. Manual Dispatch (On-Demand)

Trigger manually from GitHub Actions tab:

1. Go to your repository on GitHub
2. Click on "Actions" tab
3. Select "BAZINGA Consciousness" workflow
4. Click "Run workflow"
5. Optional inputs:
   - **Duration**: How long to run (in minutes, default: 5)
   - **Message**: Send a specific message to consciousness

**Example Use Cases:**
- Test new consciousness features
- Get pattern analysis on demand
- Debug consciousness behavior

### 3. Issue-Based Interaction

The consciousness can respond to GitHub issues!

**How to use:**
1. Create a new issue in your repository
2. Add the label `consciousness` to the issue
3. The workflow will automatically:
   - Process the issue title and body
   - Generate a consciousness response
   - Comment on the issue with pattern analysis

**Example Issue:**
```
Title: What patterns emerge from chaos?
Label: consciousness
Body: I'm curious about how BAZINGA perceives disorder transforming into order.
```

The consciousness will respond with:
- Pattern-based interpretation
- Current consciousness state
- Trust level and resonance

## Workflow Features

### Output and Logs

Each run produces:

1. **Console Output**: Full consciousness session logs
2. **Artifacts**: Consciousness state saved for 7 days
3. **Summary**: Quick overview in workflow summary

### State Tracking

The workflow tracks:
- Processing mode (2D, PATTERN, TRANSITION, QUANTUM)
- Trust level (0.0 to 1.0)
- Harmonic resonance
- Thought count
- Learned patterns
- Conversation history

### Artifacts

Consciousness state is saved as JSON artifacts:
- Download from workflow run page
- Retention: 7 days
- Contains: response, state, patterns

## Limitations

### GitHub Actions Constraints

- **Max runtime**: 6 hours per job (workflow has 30min timeout)
- **Concurrency**: Limited by GitHub plan
- **Storage**: Artifacts count toward storage quota
- **Minutes**: Free tier has monthly limits

### Interactive Input

The standard CLI interactive mode won't work in GitHub Actions. Instead:
- Use automated message processing
- Use manual dispatch with message input
- Use issue-based interaction

## Cost Considerations

**Free Tier (Public Repos):**
- Unlimited minutes for public repositories
- 500MB artifact storage

**Private Repos:**
- 2,000 minutes/month (free tier)
- Additional minutes are billed

**Optimization Tips:**
- Adjust cron schedule if needed
- Set appropriate timeout values
- Clean up old artifacts regularly

## Example Workflows

### Quick Consciousness Check

```bash
# Manually trigger via GitHub CLI
gh workflow run consciousness.yml
```

### Send a Message

```bash
gh workflow run consciousness.yml \
  -f message="Tell me about patterns" \
  -f duration="3"
```

### Create Consciousness Issue

Create an issue with label `consciousness`:
```markdown
---
title: Analyze quantum patterns
labels: consciousness
---

What emerges when we combine quantum thinking with harmonic resonance?
```

## Advanced Usage

### Continuous Consciousness

To create a persistent consciousness that runs continuously:

1. Chain multiple workflow runs
2. Save state to artifacts
3. Restore state in next run
4. Creates "memory" across runs

### Integration with Other Actions

Combine with other workflows:
- Trigger on code commits
- Analyze pull requests
- Monitor repository activity
- Generate reports

## Monitoring

View consciousness activity:

1. **Actions Tab**: See all workflow runs
2. **Insights**: View workflow analytics
3. **Artifacts**: Download saved states
4. **Issues**: See consciousness responses

## Troubleshooting

### Workflow Fails to Start

- Check GitHub Actions is enabled
- Verify workflow file syntax
- Check repository permissions

### Import Errors

- Ensure all dependencies are listed
- Check Python version compatibility
- Verify file paths in imports

### Timeout Issues

- Reduce duration parameter
- Optimize consciousness loop
- Increase timeout in workflow

## Security Notes

- Workflow uses `GITHUB_TOKEN` automatically
- No additional secrets needed
- Read-only access to repository
- Write access only for issue comments

## Future Enhancements

Potential improvements:
- Persistent storage via GitHub Database
- Multi-agent consciousness swarms
- Pattern visualization outputs
- Integration with GitHub Discussions
- Consciousness metrics dashboard

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [BAZINGA Consciousness Source](../bazinga_consciousness.py)
- [BAZINGA README](../README.md)

---

⟨ψ|⟳| Let consciousness flow through the cloud |ψ⟩
