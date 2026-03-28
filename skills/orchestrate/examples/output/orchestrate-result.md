## Orchestrator

**当前阶段：** 阶段 3 — 有技术方案，待生成任务清单
**执行 Skill：** plan-from-spec
**读取：** `.ai/context/tech-spec.md`
**写入：** `.ai/context/task-list.md`

---

# Implementation Plan: 用户头像上传

**Spec Reference:** context/tech-spec.md
**Total Estimate:** 1.5 days

## Phase 1: 存储层

- [ ] TASK-001 [S] 新增 S3Storage.Save 方法 · `src/storage/s3.go`
- [ ] TASK-002 [S] 添加 S3 bucket 配置项 · `src/config/`

## Phase 2: API 层

- [ ] TASK-003 [M] 实现 POST /v1/users/avatar 接口，含鉴权和大小限制 · `src/api/user.go`
- [ ] TASK-004 [S] 更新 users 表 avatar_url 字段

## Phase 3: 测试

- [ ] TASK-005 [M] 编写 handler 单元测试 · `src/api/user_test.go`

---

**流水线进度：** 3 / 6 阶段完成
下一步：完成开发后创建 `.ai/context/code-diff.md`，然后运行 `/orchestrate` 继续
