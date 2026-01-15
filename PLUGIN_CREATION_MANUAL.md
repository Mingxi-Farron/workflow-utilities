# Claude Code CLI Plugin Creation Manual

Technical reference for creating and publishing Claude Code CLI plugins.

---

## Table of Contents

1. [Plugin Architecture](#plugin-architecture)
2. [Directory Structure](#directory-structure)
3. [Marketplace Configuration](#marketplace-configuration)
4. [Plugin Configuration](#plugin-configuration)
5. [Command Files](#command-files)
6. [Skill Files](#skill-files)
7. [Hook Configuration](#hook-configuration)
8. [Publishing to GitHub](#publishing-to-github)
9. [Installation Methods](#installation-methods)
10. [Cache Management](#cache-management)
11. [Troubleshooting](#troubleshooting)
12. [SOPs](#standard-operating-procedures)

---

## Plugin Architecture

Claude Code CLI plugins extend functionality through:
- **Commands** - User-invocable slash commands (`/mode`, `/commit`)
- **Skills** - Markdown-based prompts that define agent behaviors
- **Hooks** - Event interceptors (PreToolUse, PostToolUse)
- **Scripts** - Shell scripts for hook handlers

### Plugin vs Marketplace

- **Plugin**: A single extension with skills, commands, hooks
- **Marketplace**: A repository containing one or more plugins

---

## Directory Structure

```
plugin-name/
├── .claude-plugin/
│   ├── marketplace.json    # Marketplace definition (required for GitHub distribution)
│   └── plugin.json         # Plugin metadata
├── commands/
│   └── command-name.md     # Slash command definitions (with YAML frontmatter)
├── skills/
│   └── skill-name.md       # Skill definitions
├── hooks/
│   └── hooks.json          # Hook configurations
├── scripts/
│   └── script-name.sh      # Hook handler scripts
├── config/
│   └── settings.json       # Plugin configuration
├── messages/
│   └── messages.json       # Localized messages
└── README.md
```

---

## Marketplace Configuration

File: `.claude-plugin/marketplace.json`

### Schema (Required Fields)

```json
{
  "name": "marketplace-name",
  "description": "Marketplace description",
  "owner": {
    "name": "Owner Name",
    "email": "owner@example.com"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Plugin description",
      "author": {
        "name": "Author Name",
        "email": "author@example.com"
      },
      "source": {
        "source": "github",
        "repo": "username/repo-name"
      }
    }
  ]
}
```

### Field Requirements

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | Yes | kebab-case, no spaces |
| `description` | string | Yes | Plain text |
| `owner` | object | Yes | Must have `name` and `email` |
| `plugins` | array | Yes | List of plugin entries |

### Plugin Entry Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | Yes | **kebab-case only** (e.g., `my-plugin`, NOT `My Plugin`) |
| `description` | string | Yes | Plain text |
| `author` | object | Yes | Must have `name` and `email` |
| `source` | object | Yes | See source formats below |
| `version` | string | No | Semver format |
| `category` | string | No | e.g., "development" |

### Source Field Format

**For GitHub-hosted plugins (required for custom marketplaces):**
```json
"source": {
  "source": "github",
  "repo": "username/repo-name"
}
```

### Invalid Keys (Will Cause Errors)

- `id` - Not recognized, do not use
- `path` - Not recognized, use `source` object instead
- `"source": "."` or `"source": "./"` - Invalid string format

---

## Plugin Configuration

File: `.claude-plugin/plugin.json`

### Schema

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description as plain string",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  },
  "license": "MIT"
}
```

### Field Requirements

| Field | Type | Required | Format |
|-------|------|----------|--------|
| `name` | string | Yes | kebab-case |
| `version` | string | Yes | Semver (e.g., "1.0.0") |
| `description` | **string** | Yes | Plain text, NOT object |
| `author` | **object** | Yes | `{ "name": "...", "email": "..." }` |
| `license` | string | No | License identifier |

### CRITICAL: Invalid Formats

```json
// ❌ WRONG - description as object
"description": {
  "en": "English",
  "zh": "中文"
}

// ✅ CORRECT - description as string
"description": "Plugin description here"

// ❌ WRONG - author as string
"author": "Author Name"

// ✅ CORRECT - author as object
"author": {
  "name": "Author Name",
  "email": "email@example.com"
}
```

### Invalid Keys (Will Cause Errors)

These fields are NOT supported in plugin.json:
- `commands` - Do not list command names here
- `skills` - Do not list skill names here
- `hooks` - Do not list hook types here
- `config` - Not recognized

Commands and skills are auto-discovered from their respective directories.

---

## Command Files

File: `commands/{command-name}.md`

### Required YAML Frontmatter

```markdown
---
description: "Brief description of what this command does"
argument-hint: "[optional] [arguments] [syntax]"
---

# /command-name - Command Title

Rest of the documentation...
```

### Field Requirements

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `description` | string | **Yes** | Shown in help/autocomplete |
| `argument-hint` | string | No | Shows argument syntax hint |

### Example: mode.md

```markdown
---
description: "Control tool call permission levels"
argument-hint: "[AUTO|TEST|SUPERVISED] or [allow|deny {tool}] or [list]"
---

# /mode - Mode Control Command

Control tool call permission levels and switch between automation modes.

## Usage

/mode                      # Show current mode
/mode AUTO                 # Switch to AUTO mode
...
```

### Example: commit.md (no arguments)

```markdown
---
description: "Trigger the git commit confirmation flow"
argument-hint: ""
---

# /commit - Git Commit Command
...
```

---

## Skill Files

File: `skills/{skill-name}.md`

Skills are markdown files with instructions for Claude. They are invoked internally by commands or hooks.

### Example Structure

```markdown
# Skill Name

## Purpose
What this skill does.

## Instructions
Step-by-step instructions for Claude to follow.

## Output Format
Expected output format.
```

---

## Hook Configuration

File: `hooks/hooks.json`

### Schema

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "matcher": {
        "tool_name": "Bash"
      },
      "handler": {
        "type": "command",
        "command": "scripts/handler.sh"
      },
      "description": "Hook description"
    }
  ]
}
```

### Hook Events

| Event | Trigger |
|-------|---------|
| `PreToolUse` | Before a tool is executed |
| `PostToolUse` | After a tool is executed |

### Handler Script Output

Scripts must output JSON to stdout:

```json
{"decision": "allow"}
```

```json
{"decision": "block", "reason": "Reason for blocking"}
```

---

## Publishing to GitHub

### Repository Setup

1. Create a public GitHub repository
2. Add required files with correct schemas:
   - `.claude-plugin/marketplace.json`
   - `.claude-plugin/plugin.json`
3. Add plugin components:
   - `commands/*.md` (with YAML frontmatter)
   - `skills/*.md`
   - `hooks/hooks.json` (if using hooks)
   - `scripts/*.sh` (if using hook scripts)

### Marketplace Registration

Add to user's global settings (`~/.claude/settings.json`):

```json
{
  "enabledPlugins": {
    "plugin-name@marketplace-name": true
  },
  "extraKnownMarketplaces": {
    "marketplace-name": {
      "source": {
        "source": "github",
        "repo": "username/repo-name"
      }
    }
  }
}
```

---

## Installation Methods

### Method 1: Marketplace (Recommended)

1. Register marketplace in global settings
2. Enable plugin in `enabledPlugins`
3. Claude Code auto-installs on startup

### Method 2: Local Path

Add to project's `.claude/settings.local.json`:

```json
{
  "plugins": [
    "C:/path/to/plugin-folder"
  ]
}
```

> **Warning**: Do NOT mix both methods for the same plugin - causes conflicts.

---

## Cache Management

Claude Code caches plugins at:
```
~/.claude/plugins/cache/{marketplace-name}/{plugin-name}/{version-or-sha}/
```

### Clear Cache (Required After Schema Fixes)

```bash
rm -rf ~/.claude/plugins/cache/{marketplace-name}
rm -rf ~/.claude/plugins/marketplaces/{marketplace-name}
```

Then restart Claude Code.

### Manual Cache Creation

For version-based caching, create structure at:
```
~/.claude/plugins/cache/{marketplace}/{plugin}/{version}/
├── .claude-plugin/
├── commands/
├── skills/
├── hooks/
├── scripts/
└── ...
```

---

## Troubleshooting

### Debug Logs Location

```
~/.claude/debug/*.txt
```

### Search for Errors

```bash
# Find latest log
ls -t ~/.claude/debug/*.txt | head -1

# Search for plugin errors
grep -i "plugin\|error\|failed\|invalid" ~/.claude/debug/{latest}.txt
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `owner: expected object, received undefined` | Missing `owner` field in marketplace.json | Add `owner` with `name` and `email` |
| `Plugin name cannot contain spaces` | Name has spaces | Use kebab-case: `my-plugin` |
| `source: Invalid input` | Wrong source format | Use object: `{"source": "github", "repo": "..."}` |
| `Unrecognized keys: "id", "path"` | Invalid fields in marketplace.json | Remove `id`, use `source` object |
| `description: expected string, received object` | Localized description object in plugin.json | Use plain string |
| `author: expected object, received string` | Author as string in plugin.json | Use object with name/email |
| `Unrecognized key: "config"` | Invalid field in plugin.json | Remove `config` |
| `commands: Invalid input` | Listed commands in plugin.json | Remove - auto-discovered |
| `skills: Invalid input` | Listed skills in plugin.json | Remove - auto-discovered |
| `hooks: Invalid input` | Listed hooks in plugin.json | Remove - defined in hooks.json |
| Skills not appearing | Missing YAML frontmatter | Add `description` frontmatter to commands |
| Using old version | Cache not cleared | Delete cache folders, restart |

---

## Standard Operating Procedures

### SOP 1: Create New Plugin

1. Create directory structure
2. Write `plugin.json`:
   - `name`: kebab-case
   - `description`: plain string
   - `author`: object with name/email
   - `version`: semver
3. Write `marketplace.json`:
   - `owner`: object with name/email
   - `plugins[].source`: GitHub object format
4. Create `commands/*.md` with YAML frontmatter:
   - `description`: required
   - `argument-hint`: if has arguments
5. Create `skills/*.md`
6. Create `hooks/hooks.json` if needed
7. Test locally first
8. Push to GitHub
9. Register marketplace in global settings
10. Restart Claude Code

### SOP 2: Debug Plugin Installation Failure

1. Check debug logs: `~/.claude/debug/*.txt`
2. Search for "ConfigParseError" or "Invalid"
3. Identify the specific field causing issues
4. Fix schema according to this manual
5. Clear cache: `rm -rf ~/.claude/plugins/cache/{marketplace}`
6. Commit and push changes
7. Restart Claude Code

### SOP 3: Fix "Skills Not Appearing"

1. Check command files have YAML frontmatter:
   ```yaml
   ---
   description: "..."
   ---
   ```
2. Clear plugin cache
3. Restart Claude Code

### SOP 4: Update Existing Plugin

1. Make changes to plugin files
2. Update version in `plugin.json`
3. Commit and push to GitHub
4. Clear local cache (if version unchanged)
5. Restart Claude Code

---

## Quick Reference: Valid Schemas

### marketplace.json
```json
{
  "name": "my-marketplace",
  "description": "Description",
  "owner": { "name": "Name", "email": "email@example.com" },
  "plugins": [{
    "name": "my-plugin",
    "description": "Description",
    "author": { "name": "Name", "email": "email@example.com" },
    "source": { "source": "github", "repo": "user/repo" }
  }]
}
```

### plugin.json
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Description as string",
  "author": { "name": "Name", "email": "email@example.com" },
  "license": "MIT"
}
```

### commands/example.md
```markdown
---
description: "What this command does"
argument-hint: "[arg1] [arg2]"
---

# /example - Example Command
...
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-15 | Initial creation based on troubleshooting session |

---

*Generated from troubleshooting session. Last updated: 2026-01-15*
