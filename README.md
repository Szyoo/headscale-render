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

## 可选 Web UI（不使用磁盘）
如果你想操作方便，可以单独部署 UI（不需要磁盘）：

1. Render → New → Web Service
2. 选择 **Deploy an existing image**
3. Image 填：`ghcr.io/gurucomputing/headscale-ui:latest`
4. Name 建议：`headscale-ui`
5. Plan 选 **Free**
6. Create Web Service
7. 进入该服务的 **Environment**，添加环境变量：
   - `HEADSCALE_URL`：你的 `server_url`
   - `HEADSCALE_API_KEY`：在 headscale 服务里执行：
     ```bash
     headscale apikeys create
     ```
8. 保存后等待 UI 部署完成，打开其 Render 分配的 URL 访问

## 说明
本项目仅作为控制面使用：已禁用 DERP/relay。
