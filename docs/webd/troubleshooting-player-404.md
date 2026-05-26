# webd 视频播放 404 排查与修复记录

## 现象

点击 webd 文件列表中的视频链接后，浏览器跳转到类似以下 URL：

```
https://dl.00o.ink/.player.htm#Phttps://dl.00o.ink/share/视频文件.mp4
```

页面返回 **404 Not Found**，视频无法播放。

---

## 架构

```
用户浏览器
  → 阿里云 ESA（CDN/加速）
    → OpenResty（1Panel-openresty-V48N 容器，反向代理）
      → webd（ghcr.io/amrice/webd 容器，端口 9212）
```

---

## 逐层排查

### 1. ESA 层 — 排除

开启 ESA 开发模式（绕过所有缓存规则）后仍然 404，确认非 CDN 缓存问题。

### 2. OpenResty 层 — 确认转发正常

```bash
docker exec 1Panel-openresty-V48N cat /www/sites/webd/proxy/root.conf
```

输出显示存在 `location ^~ / { proxy_pass http://127.0.0.1:9212; ... }`，确认反向代理规则覆盖了 `/.player.htm`。

### 3. webd 层 — 定位根因

**关键测试：**

```bash
docker exec webd sh -c 'wget -q -O- http://127.0.0.1:9212/'
# → 有响应（首页）

docker exec webd sh -c 'wget -q -O- http://127.0.0.1:9212/.player.htm'
# → 404

docker exec webd sh -c 'wget -q -O- http://127.0.0.1:9212/share/'
# → 404
```

**查看日志：**
```bash
docker logs webd
# [16:15:45] Webd.Root /data    ← 实际 root 是 /data，不是 /data/share
```

**根因：** `entrypoint.sh` 中有 `exec webd -w /data`，命令行参数 **覆盖** 了 `webd.conf` 中的 `Webd.Root /data/share`。

- webd root = `/data`
- `.player.htm` 实际位置 = `/data/share/.player.htm`
- 访问 `/.player.htm` → webd 查找 `/data/.player.htm` → **不存在 → 404**

---

## 初始尝试与发现

### 尝试 1：修改 webd 权限

给访客添加 `S` 权限（`Webd.Guest rlDS`），因为 `.player.htm` 是点号开头的隐藏文件，无 `S` 权限时 webd 拒绝访问。

**结果：** 无效。core issue 是 root 路径错位，权限不是主因。

### 尝试 2：修复 root 路径

将 `entrypoint.sh` 的 `exec webd -w /data` 改为 `exec webd`，root 完全由 `webd.conf` 控制。

**新问题：** root 切到 `/data/share` 后，`.player.htm` 出现在文件列表中，用户不希望访客看到它。

---

## 最终方案：播放器由 OpenResty 直接托管

将 `.player.htm` 从 webd 目录中移出，由 OpenResty 在反向代理层直接返回。这样：

- `.player.htm` 不在 webd 文件列表中（完全不可见）
- 访客无需 `S` 权限
- 视频播放功能正常

### 步骤

**1. 从 webd 容器导出播放器文件：**

```bash
docker cp webd:/opt/player/.player.htm /tmp/player.htm
```

**2. 复制到 OpenResty 容器：**

```bash
docker exec 1Panel-openresty-V48N mkdir -p /opt/webd_player
docker cp /tmp/player.htm 1Panel-openresty-V48N:/opt/webd_player/player.htm
```

**3. OpenResty 添加 location 规则：**

在 `location ^~ /` 的 proxy 规则**之前**插入：

```nginx
location = /.player.htm {
    root /opt/webd_player;
    try_files /player.htm =404;
}
```

（在 1Panel 面板中操作：网站 → dl.00o.ink → 配置文件 → 编辑）

**4. 删除 webd 中的 `.player.htm`：**

```bash
docker exec webd rm /data/share/.player.htm
```

**5. `entrypoint.sh` 不再需要复制 `.player.htm`，去掉那行 `cp`：**

```sh
#!/bin/sh
exec webd
```

**6. `webd.conf` 访客权限不加 `S`：**

```ini
Webd.Guest rlD
```

**7. 重启容器：**

```bash
docker restart webd 1Panel-openresty-V48N
```

---

## 请求流程（修复后）

```
浏览器请求 /.player.htm
  → ESA
    → OpenResty location = /.player.htm
      → 本地文件 /opt/webd_player/player.htm
      → ✓ 返回播放器

浏览器请求 /share/视频.mp4
  → ESA
    → OpenResty location ^~ /
      → proxy_pass webd:9212
      → ✓ webd 正常返回文件
```

---

## 相关文件

| 文件 | 变更 |
|------|------|
| `entrypoint.sh` | 移除 `-w /data` 参数，root 由 webd.conf 控制；移除 `.player.htm` 复制逻辑 |
| `webd.conf` | 访客权限 `rlD`（无 S），root 由用户自由定义 |
| `1Panel-openresty-V48N:/opt/webd_player/player.htm` | 播放器文件，由 OpenResty 直接托管 |
| OpenResty site config | 新增 `location = /.player.htm` 规则 |

---

## 关键教训

- webd 命令行参数 `-w` 优先级高于 `webd.conf` 的 `Webd.Root`
- `.player.htm` 不需要放在 webd root 下——它只是一个静态 HTML 播放器页面，完全可以在反向代理层返回
- 隐藏文件（`.` 开头）的访问需要 `S` 权限，权限同时控制列表可见性和直接访问
- 排查容器网络问题时，`docker exec <container> wget -q -O- http://127.0.0.1:<port>/path` 是快速隔离问题层级的手段
