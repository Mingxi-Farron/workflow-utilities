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
│   └── skill-name/
│       └── SKILL.md         # Skill definition (directory-based format)
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

**Self-contained plugin (most common — plugin lives in marketplace repo):**
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
      "source": "./"
    }
  ]
}
```

**Multi-plugin marketplace (plugins in separate repos):**
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
      "name": "plugin-a",
      "description": "Plugin A",
      "author": { "name": "Author", "email": "author@example.com" },
      "source": { "source": "github", "repo": "username/plugin-a" }
    },
    {
      "name": "plugin-b",
      "description": "Plugin B",
      "author": { "name": "Author", "email": "author@example.com" },
      "source": { "source": "github", "repo": "username/plugin-b" }
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
| `source` | string or object | Yes | `"./"` for self-contained, or GitHub object. See below |
| `version` | string | No | Semver format |
| `category` | string | No | e.g., "development" |

### Source Field Format

**Self-contained plugin (marketplace repo IS the plugin):**
```json
"source": "./"
```
Use this when the plugin files live in the same repo as `marketplace.json`. This is the most common pattern for single-plugin repos.

**Separate GitHub repo (marketplace lists plugins from other repos):**
```json
"source": {
  "source": "github",
  "repo": "username/repo-name"
}
```

### Invalid Keys (Will Cause Errors)

- `id` - Not recognized, do not use
- `path` - Not recognized, use `source` field instead

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

Commands are namespaced by plugin name. For a plugin named `my-plugin`, `commands/status.md` creates the slash command `/my-plugin:status`.

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

Directory: `skills/{skill-name}/SKILL.md`

Each skill is a **directory** containing a `SKILL.md` file. The directory name becomes the skill name. For a plugin named `my-plugin`, `skills/hello/SKILL.md` creates the slash command `/my-plugin:hello`.

Skills can optionally include supporting files (scripts, templates, reference docs) alongside SKILL.md.

### SKILL.md Format

```markdown
---
name: skill-name
description: "What this skill does. Use when [trigger conditions]."
---

# Skill Name

## Instructions
Step-by-step instructions for Claude to follow.

## Output Format
Expected output format.
```

### Frontmatter Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | Yes | Must match directory name |
| `description` | string | Yes | Shown in help/autocomplete; include trigger conditions |
| `user-invocable` | boolean | No | Set `false` for internal-only skills (hooks) |

### Directory Structure Example

```
skills/
├── code-review/
│   └── SKILL.md
├── handoff/
│   └── SKILL.md
└── git-guard/
    └── SKILL.md
```

---

## Hook Configuration

File: `hooks/hooks.json`

### Schema

Uses the same format as Claude Code settings hooks (event-keyed object, not a flat array):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/handler.sh",
            "timeout": 5
          }
        ],
        "description": "Hook description"
      }
    ]
  }
}
```

Use `${CLAUDE_PLUGIN_ROOT}` to reference scripts bundled with the plugin.

**IMPORTANT:** Do NOT declare `hooks/hooks.json` in `plugin.json` — it is auto-loaded by convention. Only declare additional hook files in `plugin.json`.

### Hook Events

| Event | Trigger |
|-------|---------|
| `PreToolUse` | Before a tool is executed |
| `PostToolUse` | After a tool is executed |
| `SessionStart` | New session, `/clear`, or compaction |
| `UserPromptSubmit` | Before user prompt is processed |
| `Stop` | When session ends |

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
   - `skills/*/SKILL.md`
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

## Environment Variables

Available in hook scripts and plugin commands:

| Variable | Description |
|----------|-------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installed directory. Changes on update. |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory (`~/.claude/plugins/data/{id}/`). Survives updates. |

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

### Full Uninstall (Remove All Traces)

Plugin registration can exist in **multiple locations**. To fully uninstall, check ALL of these:

```bash
# 1. Global settings
~/.claude/settings.json              # enabledPlugins, extraKnownMarketplaces

# 2. Project-level settings (in EVERY project that used the plugin)
{project}/.claude/settings.local.json  # enabledPlugins, extraKnownMarketplaces

# 3. Plugin registry
~/.claude/plugins/installed_plugins.json   # Remove plugin entry
~/.claude/plugins/known_marketplaces.json  # Remove marketplace entry

# 4. Cache and marketplace data
~/.claude/plugins/cache/{marketplace-name}/
~/.claude/plugins/marketplaces/{marketplace-name}/
```

**Common pitfall:** Clearing global settings but forgetting project-level `settings.local.json` — the plugin will still try to load when opening that project.

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
| `source: Invalid input` | Wrong source format | Use `"./"` for self-contained, or `{"source": "github", "repo": "..."}` for separate repos |
| `Plugin 'X' not found in marketplace 'Y'` | Self-contained plugin uses GitHub source instead of `"./"` | Change `plugins[].source` to `"./"` in marketplace.json |
| Plugin loads but still shows error after uninstall | Residual config in project-level `settings.local.json` | Check ALL project dirs for `enabledPlugins` entries |
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
   - `plugins[].source`: `"./"` for self-contained, or GitHub object for separate repos
4. Create `commands/*.md` with YAML frontmatter:
   - `description`: required
   - `argument-hint`: if has arguments
5. Create `skills/{name}/SKILL.md` with YAML frontmatter (`name`, `description`)
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

### marketplace.json (self-contained)
```json
{
  "name": "my-marketplace",
  "description": "Description",
  "owner": { "name": "Name", "email": "email@example.com" },
  "plugins": [{
    "name": "my-plugin",
    "description": "Description",
    "author": { "name": "Name", "email": "email@example.com" },
    "source": "./"
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
| 1.1.0 | 2026-03-22 | Fix skills format: `skills/{name}.md` → `skills/{name}/SKILL.md`; fix hooks.json schema to event-keyed object; add SKILL.md frontmatter docs; expand hook events list |
| 1.2.0 | 2026-03-22 | Fix source field: document `"./"` for self-contained plugins; add command namespacing; add env vars section; add full uninstall SOP; add new troubleshooting entries |

---

*Last updated: 2026-03-22*
