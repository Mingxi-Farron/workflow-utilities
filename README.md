# Workflow Utilities Plugin

[English](#english) | [中文](#中文)

---

<a name="english"></a>
## English

A Claude Code plugin providing workflow utilities: Git protection, mode control, and task management.

### Features

| Feature | Description |
|---------|-------------|
| **Git Guard** | Intercept git commit/push for user confirmation |
| **Mode Control** | Manage tool permission levels (AUTO/TEST/SUPERVISED) |
| **Optimization Ticket** | Task management with locking mechanism |
| **Task Execution** | Structured workflow: Review -> Test Design -> Implementation -> Verification |

### Installation

#### Option 1: Local Installation

```bash
# Copy plugin to your project
cp -r workflow-utilities/ /path/to/your/project/

# Add to .claude/settings.json
{
  "plugins": ["./workflow-utilities"]
}
```

#### Option 2: GitHub Installation

```json
{
  "plugins": ["github:Mingxi-Farron/workflow-utilities"]
}
```

### Usage

#### Natural Language (Recommended)

No need to memorize commands. Just talk to Claude:

```
"What mode am I in?"
"Switch to auto mode"
"Allow Edit"
"What tasks are there?"
"TASK-015 is done"
"Yes, commit"
```

#### Commands (Optional)

```bash
/mode                    # Show current mode
/mode AUTO               # Switch to AUTO mode
/mode SUPERVISED         # Switch to SUPERVISED mode
/mode allow Edit         # Add Edit to auto-approve
/mode deny Bash(rm *)    # Remove from auto-approve

/ticket                  # List pending tasks
/ticket show TASK-015    # Show task details
/ticket create           # Create new task
/ticket close TASK-015   # Mark task complete

/task TASK-015           # Execute full workflow for task
/task review TASK-015    # Review only (analyze design)
/task test TASK-015      # Design tests only
/task close TASK-015     # Close after verification

/commit                  # Trigger commit confirmation
```

### Modes

| Mode | Tool Permissions |
|------|------------------|
| **AUTO** | All tools auto-approved |
| **TEST** | Only Read/Glob/Grep auto-approved |
| **SUPERVISED** | Customizable (default: Read/Write/Edit/Glob/Grep auto-approved) |

### Configuration

Edit `config/plugin_config.yaml`:

```yaml
language: zh-CN  # or "en"

features:
  git_guard: true
  mode_control: true
  optimization_ticket: true
```

### License

MIT

---

<a name="中文"></a>
## 中文

Claude Code 工作流实用工具插件：Git 保护、模式控制、任务管理。

### 功能

| 功能 | 说明 |
|------|------|
| **Git Guard** | 拦截 git commit/push，需用户确认 |
| **Mode Control** | 管理工具权限级别（AUTO/TEST/SUPERVISED）|
| **Optimization Ticket** | 任务管理，含锁定机制 |
| **Task Execution** | 结构化工作流：审核 -> 测试设计 -> 实现 -> 验证 |

### 安装

#### 方式一：本地安装

```bash
# 复制插件到项目目录
cp -r workflow-utilities/ /path/to/your/project/

# 添加到 .claude/settings.json
{
  "plugins": ["./workflow-utilities"]
}
```

#### 方式二：GitHub 安装

```json
{
  "plugins": ["github:Mingxi-Farron/workflow-utilities"]
}
```

### 使用方法

#### 自然语言（推荐）

无需记忆命令，直接与 Claude 对话：

```
"现在什么模式？"
"切换到自动模式"
"允许 Edit"
"有什么任务？"
"TASK-015 完成了"
"好的，提交吧"
```

#### 命令（可选）

```bash
/mode                    # 显示当前模式
/mode AUTO               # 切换到 AUTO 模式
/mode SUPERVISED         # 切换到 SUPERVISED 模式
/mode allow Edit         # 添加 Edit 到自动批准
/mode deny Bash(rm *)    # 从自动批准移除

/ticket                  # 列出待处理任务
/ticket show TASK-015    # 显示任务详情
/ticket create           # 创建新任务
/ticket close TASK-015   # 标记任务完成

/task TASK-015           # 执行完整任务工作流
/task review TASK-015    # 仅审核（分析设计）
/task test TASK-015      # 仅设计测试
/task close TASK-015     # 验证后关闭任务

/commit                  # 触发提交确认
```

### 模式说明

| 模式 | 工具权限 |
|------|----------|
| **AUTO** | 所有工具自动批准 |
| **TEST** | 仅 Read/Glob/Grep 自动批准 |
| **SUPERVISED** | 可自定义（默认：Read/Write/Edit/Glob/Grep 自动批准）|

### 配置

编辑 `config/plugin_config.yaml`：

```yaml
language: zh-CN  # 或 "en"

features:
  git_guard: true
  mode_control: true
  optimization_ticket: true
```

### 许可证

MIT
