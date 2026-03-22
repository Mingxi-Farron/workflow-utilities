# Workflow Utilities Plugin

[English](#english) | [中文](#中文)

---

<a name="english"></a>
## English

A Claude Code plugin providing workflow utilities: Git protection, mode control, plan & handoff, and task management.

### Features

| Feature | Description |
|---------|-------------|
| **Git Guard** | Block destructive git commands (`reset --hard`, `clean -f`, `checkout -- .`, `filter-repo --force`) |
| **Mode Control** | Manage tool permission levels (AUTO/TEST/SUPERVISED) |
| **Plan** | Create structured implementation plans with Opus reasoning + progress tracking |
| **Handoff** | Create concise handoff files for unfinished tasks |
| **Plan Loader** | Auto-resume implementation sessions from latest handoff/plan |
| **Optimization Ticket** | Task management with locking mechanism |
| **Task Execution** | Structured workflow: Review -> Test Design -> Implementation -> Verification |
| **Roundtable** | Multi-perspective investigation and analysis |

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
"Make a plan for user authentication"
"Create a handoff"
"Read the latest handoff"
"What tasks are there?"
"TASK-015 is done"
"Yes, commit"
```

#### Commands (Optional)

```bash
/mode                      # Show current mode
/mode AUTO                 # Switch to AUTO mode (zero prompts)
/mode TEST                 # Switch to TEST mode (max confirmation)
/mode SUPERVISED           # Switch to SUPERVISED mode (balanced)

/plan <task-name>          # Create a new implementation plan
/plan --progress           # Update progress on latest plan
/handoff <task-name>       # Create handoff for unfinished task
/handoff --read            # Read the latest handoff file

/ticket                    # List pending tasks
/ticket show TASK-015      # Show task details
/ticket create             # Create new task
/ticket close TASK-015     # Mark task complete

/task TASK-015             # Execute full workflow for task
/task review TASK-015      # Review only (analyze design)
/task test TASK-015        # Design tests only
/task close TASK-015       # Close after verification

/commit                    # Trigger commit confirmation
```

### Hooks

The plugin includes shell hook scripts for Claude Code:

| Hook | Type | Description |
|------|------|-------------|
| `git-guard/guard-git.sh` | PreToolUse (Bash) | Blocks destructive git commands |
| `plan-loader/plan-loader.sh` | SessionStart | Auto-injects plan/handoff context for impl sessions |

Copy hooks to `.claude/hooks/` and register in `.claude/settings.json`. See each skill's SKILL.md for installation instructions.

### Modes

| Mode | Tool Permissions |
|------|------------------|
| **AUTO** | All tools auto-approved (bare tool names) |
| **TEST** | Only Read/Glob/Grep auto-approved |
| **SUPERVISED** | Customizable (default: Read/Write/Edit/Glob/Grep auto-approved) |

### Configuration

Edit `config/plugin_config.yaml`:

```yaml
language: zh-CN  # or "en"

features:
  git_guard: true
  mode_control: true
  plan: true
  handoff: true
  plan_loader: true
  optimization_ticket: true
  task_execution: true
  roundtable: true
```

### License

MIT

---

<a name="中文"></a>
## 中文

Claude Code 工作流实用工具插件：Git 保护、模式控制、计划与交接、任务管理。

### 功能

| 功能 | 说明 |
|------|------|
| **Git Guard** | 拦截危险 git 命令（`reset --hard`、`clean -f`、`checkout -- .`、`filter-repo --force`）|
| **Mode Control** | 管理工具权限级别（AUTO/TEST/SUPERVISED）|
| **Plan** | 使用 Opus 推理创建结构化实施计划 + 进度追踪 |
| **Handoff** | 为未完成任务创建简洁的交接文档 |
| **Plan Loader** | 自动从最新交接/计划恢复实施会话 |
| **Optimization Ticket** | 任务管理，含锁定机制 |
| **Task Execution** | 结构化工作流：审核 -> 测试设计 -> 实现 -> 验证 |
| **Roundtable** | 多视角调查与分析 |

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
"制定计划"
"创建交接文档"
"查看最新交接"
"有什么任务？"
"TASK-015 完成了"
"好的，提交吧"
```

#### 命令（可选）

```bash
/mode                      # 显示当前模式
/mode AUTO                 # 切换到 AUTO 模式（零确认）
/mode TEST                 # 切换到 TEST 模式（最大确认）
/mode SUPERVISED           # 切换到 SUPERVISED 模式（平衡）

/plan <任务名>             # 创建新的实施计划
/plan --progress           # 更新最新计划的进度
/handoff <任务名>          # 为未完成任务创建交接
/handoff --read            # 读取最新交接文件

/ticket                    # 列出待处理任务
/ticket show TASK-015      # 显示任务详情
/ticket create             # 创建新任务
/ticket close TASK-015     # 标记任务完成

/task TASK-015             # 执行完整任务工作流
/task review TASK-015      # 仅审核（分析设计）
/task test TASK-015        # 仅设计测试
/task close TASK-015       # 验证后关闭任务

/commit                    # 触发提交确认
```

### Hooks

插件包含 Claude Code 的 shell hook 脚本：

| Hook | 类型 | 说明 |
|------|------|------|
| `git-guard/guard-git.sh` | PreToolUse (Bash) | 拦截危险 git 命令 |
| `plan-loader/plan-loader.sh` | SessionStart | 为 impl 会话自动注入计划/交接上下文 |

将 hook 复制到 `.claude/hooks/` 并在 `.claude/settings.json` 中注册。详见各 SKILL.md 的安装说明。

### 模式说明

| 模式 | 工具权限 |
|------|----------|
| **AUTO** | 所有工具自动批准（使用裸工具名）|
| **TEST** | 仅 Read/Glob/Grep 自动批准 |
| **SUPERVISED** | 可自定义（默认：Read/Write/Edit/Glob/Grep 自动批准）|

### 配置

编辑 `config/plugin_config.yaml`：

```yaml
language: zh-CN  # 或 "en"

features:
  git_guard: true
  mode_control: true
  plan: true
  handoff: true
  plan_loader: true
  optimization_ticket: true
  task_execution: true
  roundtable: true
```

### 许可证

MIT
