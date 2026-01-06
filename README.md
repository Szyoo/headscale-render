# headscale-render
在 Render 上部署 headscale 控制面（仅注册/发现，不转发业务流量）。

## 仓库内容
- `Dockerfile`: 基于官方 headscale 镜像构建
- `headscale/config.yaml`: headscale 配置模板（仅控制面）
- `headscale/acl.hujson`: 默认允许所有 ACL
- `data/README.md`: Render 持久化盘挂载说明
- `.gitignore`: 忽略运行时数据
- `render.yaml`: Render Blueprint 模板（含可选 UI）

## server_url 是什么？应该设置为？
`server_url` 是 **客户端访问 headscale 的公网地址**，通常是 Render 分配的 HTTPS 访问地址。

示例：
```
server_url: "https://your-service.onrender.com"
```

## Render 部署步骤
1. 用本仓库创建 **Web Service（Docker）**。
2. 修改 `headscale/config.yaml` 中的 `server_url` 和 `listen_addr`。
3. Free 计划不支持持久化磁盘，数据会在重启/重部署后丢失。
4. 确保服务监听端口与 Render 分配端口一致（默认 8080）。

## 部署后初始化（Render Shell）
```bash
headscale users create <user>
headscale preauthkeys create -u <user> --expiration 24h --reusable
```

## 已加入一个常见 Web UI（可选）
Blueprint 里已加入 `headscale-ui` 服务（使用 `ghcr.io/gurucomputing/headscale-ui`）。

你需要：
1. 创建 API Key：
   ```bash
   headscale apikeys create
   ```
2. 在 Render 的 `headscale-ui` 服务里设置环境变量：
   - `HEADSCALE_URL`：你的 headscale 公网地址（同 `server_url`）
   - `HEADSCALE_API_KEY`：上一步生成的 Key

## 说明
本项目仅作为控制面使用：已禁用 DERP/relay。
