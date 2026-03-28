# Implementation Plan: 用户头像上传

**Spec Reference:** context/tech-spec.md
**Total Estimate:** 1.5 days

## Phase 1: 存储层

- [x] TASK-001 [S] 新增 S3Storage.Save 方法 · `src/storage/s3.go`
- [x] TASK-002 [S] 添加 S3 bucket 配置项 · `src/config/`

## Phase 2: API 层

- [x] TASK-003 [M] 实现 POST /v1/users/avatar 接口，含鉴权和大小限制 · `src/api/user.go`
- [x] TASK-004 [S] 更新 users 表 avatar_url 字段（已存在，无 migration）

## Phase 3: 测试

- [x] TASK-005 [M] 编写 handler 单元测试（happy path + S3 失败）· `src/api/user_test.go`
- [ ] TASK-006 [S] 补充文件类型校验的测试用例
