# ai-skills

> 一套可组装、可替换的 AI 辅助研发全流程工具集。
> 每个 skill 是一个独立的 AI 提示词模块，通过声明输入/输出类型自由组合成流水线。

[架构文档（中文）](OVERVIEW_CN.md) · [Architecture Doc (EN)](OVERVIEW.md) · [贡献指南](CONTRIBUTING.md) · [Changelog](CHANGELOG.md)

---

## 它能做什么

| Skill | 输入 | 输出 |
|-------|------|------|
| `prd-from-idea` | 想法/会议记录/草稿 | PRD 文档 |
| `spec-from-prd` | PRD + 设计稿（可选） | 技术方案 |
| `plan-from-spec` | 技术方案 | 任务清单 |
| `review-standard` | 代码 diff | Code Review 报告 |
| `release-conventional` | Review + 任务 | Changelog + 上线 checklist |

任意阶段可单独使用，也可以串成完整流水线。

---

## 快速接入

### 1. 添加为 Git Submodule

```bash
git submodule add git@github.com:Empty0Qc/ai-skills.git ai-skills
```

### 2. 初始化项目配置

```bash
sh ai-skills/setup.sh
```

这一步会自动完成：
- 创建 `.ai/context/` 目录（运行时状态，已加入 `.gitignore`）
- 生成 `.ai/pipeline.yaml`（流水线配置，需提交到 git）
- 可选安装 git hooks

### 3. 开始使用

在 Claude Code 中，创建 `.ai/context/raw-idea.md` 写下你的想法，然后运行：

```
/prd       → 生成 PRD
/spec      → 生成技术方案
/plan      → 生成任务清单
```

或者一键跑完整链路：

```
/orchestrate
```

---

## 日常使用

### 切换流水线

编辑 `.ai/pipeline.yaml`：

```yaml
# 完整 SDLC 流水线
use: ai-skills/pipelines/full-sdlc.yaml

# 只要技术方案 + 任务拆解
# use: ai-skills/pipelines/planning-only.yaml

# 只要 Review + Release Notes
# use: ai-skills/pipelines/quick-review.yaml
```

### 替换某个阶段的 Skill

```yaml
use: ai-skills/pipelines/full-sdlc.yaml
overrides:
  requirements:
    skill: prd-from-jira    # 换成你自己的 skill
```

### 人工介入

直接编辑 `.ai/context/` 下的任意 `.md` 文件，系统从编辑点继续往下走。

在文件首行加 `# LOCKED` 可防止 AI 覆盖该文件。

---

## 更新 ai-skills

```bash
cd ai-skills && git pull && cd ..
git add ai-skills
git commit -m "chore: update ai-skills"
```

> 更新前建议看下 [CHANGELOG](CHANGELOG.md) 确认有无破坏性变更（major 版本号升级表示有 breaking change）。

---

## 接入常见问题

**Q: `.ai/context/` 要提交到 git 吗？**
不要。这是运行时状态，由 `setup.sh` 自动加入 `.gitignore`。

**Q: 可以在多个项目里用同一套 ai-skills 吗？**
可以，每个项目独立 `git submodule add`，各自维护 `.ai/pipeline.yaml` 覆盖配置。

**Q: 我想换成别的 AI 模型怎么办？**
所有 skill 默认 `model_agnostic: true`，prompt 里没有写死模型。在 Claude Code 中切换模型即可，skill 不需要改动。

**Q: `git submodule add` 报错说路径已存在怎么办？**
如果之前有失败的尝试，需要先清理残留：
```bash
rm -rf ai-skills
rm -rf .git/modules/ai-skills
git submodule add git@github.com:Empty0Qc/ai-skills.git ai-skills
```

---

## 贡献新 Skill

贡献门槛很低：一个 `skill.yaml` + 一个 `prompt.md`。

```bash
cp -r ai-skills/skill-template ai-skills/skills/your-skill-name
# 填写 skill.yaml 和 prompt.md
# 添加 examples/ 样例
# 提 PR，标题格式：feat(skill): your-skill-name
```

详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## License

MIT
