# Dockerfile

# 使用 Rust 官方的构建镜像作为基础
FROM rust:latest AS builder

# 安装 Protobuf 编译器，Anki Sync Server 构建所需
RUN apt-get update && apt-get install -y protobuf-compiler && rm -rf /var/lib/apt/lists/*

# 设置容器内的构建工作目录。
# 所有的源码都将复制到这个目录中。
WORKDIR /app

# 编译 Anki Sync Server
# 最终修正：回到 Workspace 根目录的 Cargo.toml（即 /app/Cargo.toml）
# 使用 -p 或 --package 参数指定要编译的包名 anki-sync-server
# 注意：我们必须移除 --manifest-path，让它默认查找 /app/Cargo.toml
RUN cargo build --release --locked --package anki-sync-server

# 最终运行镜像
FROM debian:bookworm-slim

# 安装 Protobuf 运行时库和证书
RUN apt-get update && apt-get install -y libprotobuf-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /ankisyncdir

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /app/target/release/anki-sync-server /usr/local/bin/anki-sync-server

# 暴露端口
EXPOSE 8080

# 默认启动命令
CMD ["anki-sync-server"]

# 示例环境变量定义（请在 Docker Compose 或 k8s 中设置）
# ENV SYNC_USER1="user:password"
