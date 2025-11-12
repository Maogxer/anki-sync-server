# Anki 自托管同步服务器 (Multi-Arch)

[![Docker Build Status](https://github.com/Maogxer/anki-sync-server/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/Maogxer/anki-sync-server/actions/workflows/build-and-push.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/maogxer/anki-sync-server.svg)](https://hub.docker.com/r/maogxer/anki-sync-server)
[![License](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.en.html)


---

## ✨ 项目简介

本项目旨在提供一个**高兼容性、高效率**的 Anki 自托管同步服务器 Docker 镜像。

该镜像基于 **Anki 官方 Rust 语言实现**的同步服务器代码，通过 GitHub Actions 自动化构建，并支持多平台架构 (AMD64, ARM64)。

### 核心特性

* **高兼容性：** 基于 Anki 官方 Rust 代码，保证与最新的 Anki 客户端（包括桌面版和 AnkiDroid）实现**增量同步**，解决第三方服务器常见的完全同步问题。
* **多平台支持：** 支持 `linux/amd64` 和 `linux/arm64` 架构，兼容绝大多数 VPS 和树莓派等设备。
* **自动化更新：** 通过定时任务自动检查 Anki 官方仓库的最新稳定版本，并进行构建和推送。
* **轻量高效：** 使用多阶段构建，最终镜像体积小巧，运行高效。

---

## 🚀 快速部署 (Docker Compose)

最推荐使用 Docker Compose 部署，它能简化配置和数据持久化管理。

### 1. 前提条件

* 已安装 **Docker** 和 **Docker Compose**（或 `docker compose` CLI）。
* 已开放服务器的 `8080` 端口。

### 2. 创建部署文件

在您的服务器上创建一个名为 `docker-compose.yml` 的文件：

```yaml
version: '3.8'

services:
  anki-sync-server:
    # 替换为您自己的镜像名称
    image: YOUR_USERNAME/anki-sync-server:latest 
    container_name: anki-sync-server
    
    # 意外退出时自动重启
    restart: unless-stopped
    
    # 端口映射：外部端口:内部端口
    ports:
      - "8080:8080"
      
    environment:
      # *** 必填：定义至少一个用户和密码（格式：用户名:密码） ***
      # 请务必修改为您自己的安全凭证！
      SYNC_USER1: "your_anki_username:your_strong_password"
      
      # 可选：如果需要多个用户，请按 SYNC_USER2, SYNC_USER3, ... 格式添加
      # SYNC_USER2: "user2:pass2"

    volumes:
      # **重要：** 挂载数据卷，用于持久化您的卡片和媒体文件
      # 请替换 /path/to/anki_data 为您主机上的绝对路径
      - /path/to/anki_data:/ankisyncdir
```


### 3. 启动服务

在 `docker-compose.yml` 所在的目录下执行：

```bash
docker compose up -d

服务启动后，您的同步服务器即可通过 `http://[您的服务器IP]:8080` 访问。

---

## 📱 Anki 客户端配置

要让您的 Anki 客户端连接到自托管服务器，您需要修改客户端的同步设置。

### 1. Anki 桌面版 (Desktop)

* 进入 **工具 (Tools)** > **偏好设置 (Preferences)**。
* 在 **网络 (Network)** 标签下，勾选 **自定义同步服务器 (Custom sync server)**。
* 输入服务器地址和端口，例如：`http://[您的服务器IP]:8080`。

### 2. AnkiDroid (Android)

* 进入 **设置 (Settings)** > **高级设置 (Advanced)**。
* 找到 **自定义同步服务器 (Custom Sync Server)**。
* **服务器 URL：** `http://[您的服务器IP]:8080/`
* **媒体 URL：** `http://[您的服务器IP]:8080/msync/`
* 返回同步界面，输入您在 Docker 环境中设置的用户名和密码。

### ⚠️ **重要提示：解决同步中断问题**

如果您在 AnkiDroid 上遇到同步中断（例如熄屏中断），请务必：

> 进入安卓 **设置** > **应用** > **AnkiDroid** > **电池**，将 AnkiDroid 的电池使用权限设置为 **“不受限制”** 或 **“不允许优化”**。

## 🛡️ 安全与维护

* **HTTPS 推荐：** 服务器默认通过未加密的 HTTP 运行。如果您将其暴露在公网，强烈建议使用 **Nginx/Caddy 等反向代理**配置 **HTTPS** 来加密您的数据传输。
* **更新：** 要更新到最新版本的 Anki 同步服务器，只需执行：
    ```bash
    docker compose pull
    docker compose up -d
    ```

---

## ⚙️ 构建与自动化

本项目通过 GitHub Actions 实现自动化构建。构建流程如下：

1.  定时触发（或手动触发）。
2.  调用 GitHub API 获取 Anki 官方仓库的**最新稳定版本标签**。
3.  使用 `actions/checkout` 克隆该标签的代码。
4.  使用 Docker Buildx 构建 **`linux/amd64`** 和 **`linux/arm64`** 多平台镜像。
5.  将镜像推送到 Docker Hub。

**贡献：** 欢迎对构建脚本和配置提出改进建议！



