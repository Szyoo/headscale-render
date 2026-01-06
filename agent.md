# Render 上的 Headscale 项目创建指引（Git 管理）

本文用于在 Render 平台上，通过 Git 仓库方式部署并运行 headscale。  
目标是构建一个**只承担控制面职责**的 headscale 服务，不承载任何业务流量，不启用中继。

---

## 0. 设计前提（不可偏离）

- Render 仅作为部署平台
- headscale 只承担控制面（注册 / 节点发现）
- 不转发任何业务流量
- 禁用 DERP / relay
- Git 为唯一配置与版本管理入口
- 项目可被 AI 或他人复现

---

## 1. Render 项目类型选择

### 1.1 服务类型

选择：

- **Web Service**
  - 长期运行
  - 对外提供 HTTPS 访问
  - 支持自定义端口

不选择：
- Background Worker（无外部访问）
- Cron Job（不适合常驻服务）

---

## 2. Git 仓库基本要求

### 2.1 仓库职责边界

Git 仓库中只包含：

- headscale 运行所需文件
- 配置模板（可参数化）
- Render 启动所需定义

不包含：

- 任何密钥明文
- 节点私钥
- 实际注册数据目录

---

## 3. 推荐的仓库结构（逻辑结构）

```text
headscale-render/
├── README.md
├── headscale/
│   └── config.yaml        # headscale 主配置（模板化）
├── data/
│   └── README.md          # 说明该目录在 Render 中作为持久化卷
├── render.yaml (可选)
└── .gitignore
