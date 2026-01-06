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

## 免费版无 Shell 时获取 API Key（自动输出到日志）
本项目在容器启动时会自动生成一个 API Key，并打印到日志中：

1. 部署 headscale 服务
2. 打开 Render 日志，搜索 `HEADSCALE_API_KEY=`
3. 把该值填到 UI 服务的 `HEADSCALE_API_KEY`

注意：免费版无持久化磁盘，重启/重部署会重新生成 Key，需要更新 UI 环境变量。

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

## UI 无法连接（Missing Bearer）解决方案
`headscale-ui` 官方要求 UI 与 headscale 在同一子域名，或通过反向代理处理 CORS。
Render 会给不同服务分配不同子域名，因此会出现 `missing "Bearer " prefix`。

最稳妥的办法是新增一个“网关”服务，把 UI 和 headscale 合并到同一域名：

1. 新建一个 Web Service（Docker）
2. Dockerfile 路径：`gateway/Dockerfile`
3. 设置环境变量：
   - `HEADSCALE_UPSTREAM`: `https://headscale-6bpk.onrender.com`
   - `UI_UPSTREAM`: `https://headscale-ui-5zwu.onrender.com`
4. 部署完成后，访问网关地址：
   - UI 地址：`https://<gateway>.onrender.com/web`
   - API 地址：`https://<gateway>.onrender.com`
5. 在 UI 的设置里把 Headscale URL 改成 `https://<gateway>.onrender.com`

## 说明
本项目仅作为控制面使用：已禁用 DERP/relay。
