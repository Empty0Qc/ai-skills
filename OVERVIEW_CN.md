# ai-skills — 架构设计文档（持续更新）

> **本文件始终反映系统当前状态。**
> 涵盖架构决策、对外接入说明、踩坑记录。
> 每次完成有意义的变更后更新。

---

## 这是什么

一套可组装、模型无关的 AI Skill 工具集，覆盖软件研发全生命周期。

Skill 是原子变换：每个 skill 接受一种或多种**工件类型**作为输入，产出恰好一种工件类型。任意阶段可被替换、可被跳过。流水线通过组合 skill 构建，像 Unix 管道一样。

**核心理念：**
- Skill 是函数，不是脚本
- 工件（Artifact）是接口协议
- 人随时可以介入
- 不绑定任何模型（默认模型无关）

---

## 架构

### 三层结构

```
┌─────────────────────────────────────────────┐
│  流水线  pipelines/*.yaml                    │
│  声明阶段顺序和 skill 分配                   │
├─────────────────────────────────────────────┤
│  Skill  skills/*/skill.yaml + prompt.md     │
│  原子变换：工件 → 工件                       │
├─────────────────────────────────────────────┤
│  工件 Schema  core/_schema/artifacts.yaml   │
│  类型系统 — 定义什么可以在 skill 间流动      │
└─────────────────────────────────────────────┘
```

### 工件流转（默认 full-sdlc 流水线）

```
raw-idea
  └─[prd-from-idea]──► prd
                         └─[spec-from-prd]──► tech-spec
                                               └─[plan-from-spec]──► task-list
                                                                        │（人工开发）
                                                                     code-diff
                                                                        └─[review-standard]──► review
                                                                                                └─[release-conventional]──► release-notes
```

带 `?` 的是可选输入：
- `design-assets?` 可以喂给 `spec-from-prd`
- `tech-spec?` 可以喂给 `review-standard`

### 运行时状态机

状态存在宿主项目的 `.ai/context/` 目录里（不在本 repo）。

```
工件文件不存在  →  阶段 PENDING（等待）
所有必须输入存在  →  阶段 READY（可执行）
skill 执行中  →  阶段 RUNNING
工件文件已写入  →  阶段 DONE（完成）
工件文件被删除  →  阶段重置为 PENDING（下游同步重置）
```

Orchestrator（`core/_runtime/orchestrator.md`）读取当前 context 状态，判断哪些阶段可以执行——逻辑与 Makefile 评估构建目标完全一致。

**人工覆盖：** 在任意工件文件首行写 `# LOCKED`，Orchestrator 永远不会覆盖它。

---

## 仓库结构

```
ai-skills/
  core/
    _schema/
      artifacts.yaml        ← 所有工件类型定义
    _runtime/
      orchestrator.md       ← Orchestrator skill（可自举）
      hooks/
        post-commit.sh      ← commit 后提示运行 /review
        pre-push.sh         ← push 前检查未完成任务
  skills/
    prd-from-idea/          ← raw-idea → prd
    spec-from-prd/          ← prd → tech-spec
    plan-from-spec/         ← tech-spec → task-list
    skill-template/         ← 新 skill 脚手架，复制此目录开始
  pipelines/
    full-sdlc.yaml          ← 完整 SDLC 流水线
    planning-only.yaml      ← 只有方案设计 + 任务拆解
    quick-review.yaml       ← 只有 review + release
  setup.sh                  ← 宿主项目一键初始化
  README.md                 ← 快速接入指南
  CONTRIBUTING.md           ← 如何贡献新 skill
  OVERVIEW.md               ← 架构文档（英文版）
  OVERVIEW_CN.md            ← 架构文档（本文件）
```

---

## 接入你的项目

### 方式一：Git Submodule（推荐）

```bash
# 添加 submodule
git submodule add git@github.com:Empty0Qc/ai-skills.git ai-skills

# 初始化
sh ai-skills/setup.sh
```

setup.sh 自动创建：
- `.ai/context/` — 运行时状态（自动加入 `.gitignore`）
- `.ai/pipeline.yaml` — 流水线配置（需要提交到 git）
- 可选安装 git hooks

### 方式二：直接 clone

```bash
git clone git@github.com:Empty0Qc/ai-skills.git ai-skills
sh ai-skills/setup.sh
```

无 submodule 追踪，更新需要手动操作。

### 更新 ai-skills

```bash
cd ai-skills && git pull && cd ..
git add ai-skills
git commit -m "chore: update ai-skills"
```

### 宿主项目需要的 .gitignore 条目

```gitignore
# ai-skills 运行时状态（由 setup.sh 自动添加）
.ai/context/
```

`.ai/pipeline.yaml` **需要**提交——它记录了本项目使用哪套流水线和覆盖配置。

---

## Skill 合约说明

每个 skill 在 `skill.yaml` 里声明类型签名：

```yaml
consumes:
  - prd             # 必须输入
  - design-assets?  # 可选输入（? 后缀）
produces:
  - tech-spec       # 永远只有一个输出
```

`?` 后缀表示该 skill 没有这个输入也能运行，但有的话输出质量更高。

**替换 skill：** 只要满足相同合约的 skill 都可以直接替换。在 `.ai/pipeline.yaml` 里覆盖：

```yaml
use: ai-skills/pipelines/full-sdlc.yaml
overrides:
  requirements:
    skill: prd-from-jira    # 替换为你自己的 skill
```

---

## 当前 Skill 列表

| Skill | 消费 | 产出 | 状态 |
|-------|------|------|------|
| `prd-from-idea` | `raw-idea` | `prd` | ✅ v0.1.0 |
| `spec-from-prd` | `prd`, `design-assets?` | `tech-spec` | ✅ v0.1.0 |
| `plan-from-spec` | `tech-spec` | `task-list` | ✅ v0.1.0 |
| `review-standard` | `code-diff`, `tech-spec?` | `review` | ✅ v0.1.0 |
| `release-conventional` | `review`, `task-list?` | `release-notes` | ✅ v0.1.0 |
| `orchestrate` | `*`（读取所有已有 artifact） | `*`（调用对应 skill） | ✅ v0.1.0 |

---

## 当前流水线

| 流水线 | 阶段 | 适用场景 |
|--------|------|----------|
| `full-sdlc` | 想法→PRD→方案→计划→Review→发布 | 从零开始的新功能 |
| `planning-only` | PRD→方案→计划 | 已有 PRD，需要技术拆解 |
| `quick-review` | Review→发布说明 | 只需 Review + Changelog |

---

## 设计决策与取舍

### 为什么用 MD 文件传递工件状态，而不是数据库？

Git 原生、人可读、零基础设施。`.ai/context/` 相当于构建缓存——删掉重新生成即可。结构化数据需求（如任务追踪集成）可以之后通过 MCP 叠加，不影响核心设计。

### 为什么每个 skill 只能有一个输出？

保持有向无环图可预测。如果一个 skill 自然产出多个工件（如同时输出方案 + 任务清单），应该拆成两个 skill 通过流水线组合。这样每个 skill 可以独立测试。

### 为什么用 YAML 声明合约，而不是 TypeScript / JSON Schema？

不需要任何工具即可编辑。贡献者只需要文本编辑器就能新增一个 skill。Schema 验证可以之后叠加，不影响格式。

### 为什么不用 LangChain / LlamaIndex 等框架？

这是一个**提示词工程系统**，不是 ML 框架。"运行时"就是 AI 模型本身。引入框架只会增加抽象层而无收益。后续 MCP 集成（用于外部工具访问）比 Python 编排框架更适合这个场景。

---

## 踩坑记录

- **2026-03-28** — 初始架构确立。关键洞察：以**工件类型**而非 skill 名称作为接口协议，才是让系统可组合的根本。Skill 是实现细节，Artifact 才是 API。

- **2026-03-28** — 发布至 GitHub（`git@github.com:Empty0Qc/ai-skills.git`），作为 submodule 接入 mk_p。**踩坑**：`git submodule add` 失败时会在 `.git/modules/{name}` 留下残留状态，下次重试前必须先 `rm -rf .git/modules/ai-skills`，否则依然报错。

- **2026-03-29** — 完成 `review-standard`、`release-conventional`、`orchestrate` 三个 skill。全部 6 个核心 skill 就位，`full-sdlc` 流水线首次完整可用。`orchestrate` 设计了"最多连续自动执行 3 步后暂停"的机制，防止用户失去对流程的感知。

---

## 路线图

- [x] `review-standard` skill
- [x] `release-conventional` skill
- [x] Orchestrator 作为 Claude Code skill（让 `/orchestrate` 可用）
- [ ] examples/ 自动化测试运行器
- [ ] `prd-from-figma` skill（MCP Figma 集成）
- [ ] GitHub Actions CI（skill PR 自动验证）
- [ ] 流水线状态可视化（VSCode 插件或 Web 面板）
