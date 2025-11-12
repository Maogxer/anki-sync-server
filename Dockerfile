# Dockerfile

# --- 第一阶段：构建 ---
# 官方 Dockerfile 通常使用 Alpine Linux 作为构建基础，以减小镜像大小。
FROM rust:1.82.0-alpine3.20 AS builder

# 这是一个必要的构建参数，用于指定 Anki Git 仓库的标签/版本。
ARG ANKI_VERSION

# 安装 Protobuf 编译器，Anki Sync Server 构建所需。
RUN apk update && apk add --no-cache build-base protobuf && rm -rf /var/cache/apk/*

# 使用 cargo install 直接从 Git 仓库的指定版本标签安装 anki-sync-server
# 这绕过了复杂的 Workspace 路径问题。
RUN cargo install --git https://github.com/ankitects/anki.git \
    --tag ${ANKI_VERSION} \
    --root /anki-server \
    anki-sync-server

# --- 第二阶段：运行 ---
# 使用一个极简的基础镜像来运行最终的二进制文件。
FROM alpine:3.20.2

# 创建运行用户和目录
RUN adduser -D anki-sync-user -h /anki_data
WORKDIR /anki_data
USER anki-sync-user

# 从构建阶段复制编译好的二进制文件
# 文件位于 /anki-server/bin/anki-sync-server
COPY --from=builder /anki-server/bin/anki-sync-server /usr/local/bin/

# 暴露端口
EXPOSE 8080

# 默认启动命令
CMD ["anki-sync-server"]

# 示例环境变量定义（请在 Docker Compose 或 k8s 中设置）
# ENV SYNC_USER1="user:password"
# ENV SYNC_BASE="/anki_data"
