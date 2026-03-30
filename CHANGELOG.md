# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - 2026-03-30

### 🚀 架构演进 (Architecture Evolution)
- **端云协同架构确立**: 新增 `docs/fastapi_edge_cloud_architecture.md`，彻底扭转了纯端侧算力不足的现实痛点。确立了以 FastAPI 为核心的端云微服务底座，引入了复合指令切割 (Intent Splitting) 与 Command ID 防竞态机制。
- **隐私合规体系落地**: 新增 `docs/ai_privacy_compliance_guidelines.md`，从 GDPR 和 PIPL 视角，制定了端侧 Isar 数据库的 AES-256 加密、云端前置 NER 脱敏、内存阅后即焚、以及数据飞轮的强 Opt-in 授权墙标准。
- **数据工厂与评估体系**: 新增 `model_forge/data_evaluation_and_synthesis_rules.md`，明确了基于“5条黄金规则”的 SFT 数据合成流水线，并创新性地引入了 `LLM-as-a-Judge` 进行云端二次隐私清洗与质量打分。
- **架构复盘更新**: 更新了 `docs/honest_architecture_reflection.md`，加入了“走向生产级的端云协同”复盘内容，正视并解决了此前 Mock 引擎留下的架构空白。

### ✨ 文档与可视化更新 (Documentation & Visualization)
- **README 重构**: 深度提炼了项目的四大核心亮点（零幻觉控制、全栈隐私护城河、Isolate 异步与指令解耦、数据飞轮闭环），并补充了核心 Todo 清单 (Roadmap) 引导后续开源社区开发。
- **全局架构图重绘**: 采用兼容性极佳的 Mermaid `flowchart` 标准语法，重构并渲染了 4 张全局大图（业务流程图、产品微服务架构图、核心数据流转图、关键交互时序图），彻底解决了预览器报错的问题。
- **指标与验收标准 (KPIs)**: 在 FastAPI 架构文档中补齐了端到端延迟（<1.5s）、缓存命中率（>40%）等工程化考核标准。
