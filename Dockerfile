# Dockerfile

# 使用 Rust 官方的构建镜像作为基础
FROM rust:latest AS builder

# 安装 Protobuf 编译器，Anki Sync Server 构建所需
RUN apt-get update && apt-get install -y protobuf-compiler && rm -rf /var/lib/apt/lists/*

# 设置容器内的构建工作目录。
# 所有的源码都将复制到这个目录中。
WORKDIR /app

# 编译 Anki Sync Server
# 注意：ankitects/anki 仓库中同步服务器的源码在 rslib/syncv3/
# 最终修正：Manifest 文件位于 rslib/syncv3/Cargo.toml
# 我们需要显式告诉 cargo 去哪里找。
RUN cargo build --release --locked --bin anki-sync-server --manifest-path rslib/sync/Cargo.toml

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
# ENV SYNC_USER1="user:password"# ENV SYNC_USER1="user:password"
