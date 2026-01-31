# 添加新 Skill 到 workflow-utilities 插件

本文档记录向 workflow-utilities 插件添加新 skill 的完整流程。

---

## 概述

添加新 skill 需要修改以下文件：

| 文件 | 用途 | 必需 |
|------|------|------|
| `{skill-name}/SKILL.md` | Skill 定义和逻辑 | ✓ |
| `commands/{cmd}.md` | 用户命令接口 | ✓ |
| `config/plugin_config.yaml` | 功能开关 | ✓ |
| `.claude-plugin/plugin.json` | 插件元数据 | ✓ |
| `.claude-plugin/marketplace.json` | Marketplace 注册 | ✓ |
| `.claude/settings.local.json` | 权限配置 | ✓ |
| `.claude/plans/plugin-install-plan.md` | 安装测试文档 | 推荐 |

---

## Step 1: 创建 Skill 目录和 SKILL.md

在插件根目录创建 skill 文件夹：

```
workflow-utilities/
└── {skill-name}/
    └── SKILL.md
```

### SKILL.md 格式

```markdown
---
name: {skill-name}
version: "1.0.0"
description: 简短描述
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
---

# {Skill Name}

## 功能描述
...

## 使用方式
...

## 自然语言触发词
- "执行 xxx"
- "do xxx"
```

**关键字段：**
- `name`: skill 标识符，与目录名一致
- `user-invocable: true`: 允许用户直接调用
- `allowed-tools`: skill 可使用的工具列表

---

## Step 2: 创建命令文件

在 `commands/` 目录创建命令定义：

```
workflow-utilities/
└── commands/
    └── {cmd}.md
```

### 命令文件格式

```markdown
---
description: "命令简短描述"
argument-hint: "[subcommand] {arg}"
---

# /{cmd} - 命令标题

## Usage

\`\`\`
/{cmd} {arg}              # 基本用法
/{cmd} subcommand {arg}   # 子命令
\`\`\`

## Examples
...

## Implementation

Calls `{skill-name}/SKILL.md` for execution logic.
```

---

## Step 3: 更新配置文件

### 3.1 plugin_config.yaml

添加功能开关：

```yaml
# config/plugin_config.yaml
features:
  git_guard: true
  mode_control: true
  optimization_ticket: true
  task_execution: true
  {new_skill}: true          # <-- 添加
```

### 3.2 plugin.json

更新描述和版本：

```json
{
  "name": "workflow-utilities",
  "version": "1.2.0",                           // <-- 版本号递增
  "description": "..., {new feature}",          // <-- 添加描述
  "author": { ... },
  "license": "MIT"
}
```

### 3.3 marketplace.json (关键！)

**必须同步更新**，否则 skill 不会被系统识别：

```json
{
  "name": "workflow-utilities",
  "description": "..., {new feature}",          // <-- 同步描述
  "owner": { ... },
  "plugins": [
    {
      "name": "workflow-utilities",
      "description": "..., {new feature}",      // <-- 同步描述
      "source": "./",
      "version": "1.2.0"                        // <-- 同步版本号
    }
  ]
}
```

---

## Step 4: 添加权限

在项目的 `.claude/settings.local.json` 添加 skill 权限：

```json
{
  "permissions": {
    "allow": [
      "Skill(workflow-utilities:mode)",
      "Skill(workflow-utilities:ticket)",
      "Skill(workflow-utilities:commit)",
      "Skill(workflow-utilities:task)",
      "Skill(workflow-utilities:{new-cmd})"     // <-- 添加
    ]
  }
}
```

**注意：** 权限名称使用命令名（如 `task`），不是 skill 目录名（如 `task-execution`）。

---

## Step 5: 更新安装文档

在 `.claude/plans/plugin-install-plan.md` 添加测试项：

```markdown
### 功能测试

重启 Claude Code 后测试：

\`\`\`
/mode          # 应显示当前模式
/ticket        # 应显示任务列表
/commit        # 应触发提交确认流程
/task          # 应显示任务执行帮助
/{new-cmd}     # <-- 添加新命令测试
\`\`\`

## 成功标准

- [ ] `/{new-cmd}` 命令可用    // <-- 添加
```

---

## Step 6: 重新加载插件

修改完成后，必须重启 Claude Code 使配置生效。

可选：使用 CLI 重新安装插件：

```bash
claude plugin uninstall workflow-utilities@workflow-utilities
claude plugin install workflow-utilities@workflow-utilities --scope local
```

---

## 常见问题

### Q1: Skill 定义正确但系统不识别？

检查清单：
- [ ] `marketplace.json` 描述是否包含新功能？
- [ ] `marketplace.json` 版本是否与 `plugin.json` 一致？
- [ ] `settings.local.json` 是否添加了 `Skill(workflow-utilities:{cmd})` 权限？
- [ ] 是否重启了 Claude Code？

### Q2: 命令名和 Skill 目录名的关系？

| 类型 | 命名 | 示例 |
|------|------|------|
| Skill 目录 | 描述性名称 | `task-execution/` |
| 命令文件 | 简短命令 | `commands/task.md` |
| 权限配置 | 使用命令名 | `Skill(workflow-utilities:task)` |
| 用户调用 | 使用命令名 | `/task` 或 `workflow-utilities:task` |

### Q3: 如何调试 skill 加载？

1. 检查 Claude Code 启动日志
2. 运行 `claude plugin list` 确认插件状态
3. 运行 `claude plugin validate ./workflow-utilities` 验证结构

---

## 文件清单模板

添加名为 `example-skill` 的新 skill：

```
workflow-utilities/
├── example-skill/
│   └── SKILL.md                    # [新建] skill 定义
├── commands/
│   └── example.md                  # [新建] 命令接口
├── config/
│   └── plugin_config.yaml          # [修改] 添加 example_skill: true
├── .claude-plugin/
│   ├── plugin.json                 # [修改] 更新描述和版本
│   └── marketplace.json            # [修改] 同步描述和版本
└── docs/
    └── adding-skills.md            # 本文档

项目配置：
.claude/
├── settings.local.json             # [修改] 添加 Skill 权限
└── plans/
    └── plugin-install-plan.md      # [修改] 添加测试项
```

---

## 故障排除案例

### Case 1: Skill 文件存在但命令不可用（2026-01-29）

**症状**：
- `/task` 命令不被识别
- 系统提示中只显示 `commit`、`mode`、`ticket`，缺少 `task`
- 所有文件结构正确，权限已配置

**诊断过程**：

```bash
# Step 1: 检查插件版本
claude plugin list

# 输出显示：
#   workflow-utilities@workflow-utilities
#   Version: 1.0.0    <-- 问题！plugin.json 是 1.1.0
#   Scope: local
#   Status: √ enabled

# Step 2: 检查 marketplace 来源
claude plugin marketplace list

# 输出显示：
#   workflow-utilities
#   Source: Git (https://github.com/...)  <-- 指向 GitHub，不是本地！
```

**根本原因**：

| 层级 | 期望 | 实际 | 问题 |
|------|------|------|------|
| `plugin.json` | 1.1.0 | 1.1.0 | ✓ |
| Marketplace 来源 | 本地目录 | GitHub | ✗ |
| 已安装版本 | 1.1.0 | 1.0.0 | ✗ |

Marketplace 指向 GitHub 仓库的旧版本 (1.0.0)，而本地目录已更新到 1.1.0（包含 task skill）。
安装命令从 marketplace 缓存拉取，导致始终安装旧版本。

**解决方案**：

```bash
# 1. 移除旧 marketplace（指向 GitHub）
claude plugin marketplace remove workflow-utilities

# 2. 添加本地目录作为 marketplace
claude plugin marketplace add ./workflow-utilities

# 3. 禁用旧插件（注意 scope）
claude plugin disable workflow-utilities@workflow-utilities --scope project

# 4. 重新安装（从本地 marketplace）
claude plugin install workflow-utilities@workflow-utilities --scope local

# 5. 验证版本
claude plugin list
# 应显示 Version: 1.1.0

# 6. 重启 Claude Code
```

**预防措施**：

添加新 skill 后，确保：
1. 更新 `plugin.json` 版本号
2. 同步更新 `marketplace.json` 版本号
3. 如果 marketplace 指向远程仓库，需要先 push 更新
4. 或者切换到本地 marketplace 进行开发测试

---

### Case 2: Scope 冲突导致卸载失败

**症状**：

```
× Failed to uninstall plugin: Plugin is installed at project scope, not local
```

**原因**：插件同时存在于多个 scope（project + local），CLI 无法确定卸载哪个。

**解决方案**：

```bash
# 明确指定 scope
claude plugin disable workflow-utilities@workflow-utilities --scope project
claude plugin disable workflow-utilities@workflow-utilities --scope local

# 然后重新安装到目标 scope
claude plugin install workflow-utilities@workflow-utilities --scope local
```

---

## 版本历史

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-01-29 | 1.0 | 初版，基于 task-execution skill 调试经验 |
| 2026-01-29 | 1.1 | 添加故障排除案例：marketplace 版本不匹配问题 |
