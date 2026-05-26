# Webd — 90KB 轻量自建网盘

[![Docker Build & Push](https://github.com/amrice/webd/actions/workflows/docker-build.yml/badge.svg)](https://github.com/amrice/webd/actions/workflows/docker-build.yml)

一个仅 90KB 的轻量级 Web 文件分享/管理服务器（非开源，提供二进制下载）。

---

## 📦 Docker 部署（推荐）

一行命令启动：

```bash
docker run -d --name webd \
  -p 9212:9212 \
  -v /your/data:/data \
  -v /your/webd.conf:/etc/webd.conf:ro \
  ghcr.io/amrice/webd:latest
```

或用 docker-compose：

```yaml
version: "3.8"
services:
  webd:
    image: ghcr.io/amrice/webd:latest
    container_name: webd
    restart: unless-stopped
    ports:
      - "9212:9212"
    volumes:
      - ./data:/data
      - ./webd.conf:/etc/webd.conf:ro
```

启动后访问 `http://你的IP:9212`。

---

## ⚙️ 配置文件 `webd.conf`

```ini
# 网盘文件根目录
Webd.Root  /data

# 监听地址和端口
Webd.Listen 0.0.0.0:9212

# 管理员用户 — 全部权限
Webd.User rlumSDT admin 你的密码

# 访客权限 — 仅浏览和下载（设为 0 可禁用访客）
Webd.Guest rlD
```

### 权限 Tag 说明

| Tag | 含义 |
|-----|------|
| `r` | 访问/下载文件 |
| `l` | 列出文件列表 |
| `u` | 上传文件 |
| `m` | 删除/移动/重命名 |
| `S` | 显示隐藏文件（点开头） |
| `D` | 链接加 download 属性（点击直接下载） |
| `T` | 网页播放媒体文件 |

---

## 🚀 命令行快速启动

### Linux
```bash
./webd -w /home/user/share -u rlum:user:pass
```

### Windows
```cmd
webd.exe -w D:\sharedata -u rlum:user:pass
```

然后打开 `http://127.0.0.1:9212`。

---

## ✨ 特性

- 程序仅 **60~90 KB**，内置 Web 服务器，零依赖，解压即用
- 支持 **Windows / Linux / OpenWrt / Armbian / Android**（通过 adb）
- 灵活的权限控制：访问、列表、上传、删除/重命名、显示隐藏文件均可独立配置
- 视频文件可直接在浏览器中播放
- 支持拖拽上传、文件夹上传、剪贴板粘贴上传
- 支持多用户（最多 3 个），共享同一目录，不同权限

---

## 📥 直接下载二进制

[下载最新版本](https://webd.cf/webd/webd_dl/20240223/)

---

## 📂 文件导航

| 文件 | 说明 |
|------|------|
| [Dockerfile](Dockerfile) | Docker 镜像构建文件 |
| [docker-compose.yml](docker-compose.yml) | Compose 部署模板 |
| [entrypoint.sh](entrypoint.sh) | 容器启动脚本 |
| [webd.conf](webd.conf) | webd 配置文件模板 |
| [docs/webd/troubleshooting-player-404.md](docs/webd/troubleshooting-player-404.md) | 视频播放 404 排查与修复记录 |

---

## 🔗 链接

- 官方文档: https://webd.cf/webd/
- 中文介绍: https://webd.cf/webd/webd.zh.html
- 上游仓库: https://github.com/webd90kb/webd
- Docker 镜像: `ghcr.io/amrice/webd:latest`
- 联系方式: zhngq2312@gmail.com

---

## 📸 截图

![上传](https://github.com/webd90kb/webd/blob/master/docs/webd/webd_images/image_10_upload.png)
![列表](https://github.com/webd90kb/webd/blob/master/docs/webd/webd_images/image_03_list.png)
![选中](https://github.com/webd90kb/webd/blob/master/docs/webd/webd_images/image_07_chosen.png)
![剪切](https://github.com/webd90kb/webd/blob/master/docs/webd/webd_images/image_08_cut_1.png)
