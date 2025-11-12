# Dockerfile

# 使用 Rust 官方的构建镜像作为基础
FROM rust:latest AS builder

# 安装 Protobuf 编译器，Anki Sync Server 构建所需
RUN apt-get update && apt-get install -y protobuf-compiler && rm -rf /var/lib/apt/lists/*

# 设置容器内的构建工作目录。
# 所有的源码都将复制到这个目录中。
WORKDIR /app

# **注意：我们移除 RUN git clone ...**
# 这里的 ADD/COPY 动作由 Docker Buildx 自动执行，
# 它将 GitHub Actions 提供的 'anki-repo' 目录内容复制到容器的 /app 目录。

# 由于 ankitects/anki 仓库的 Dockerfile 并不在根目录，我们需要手动切换到同步服务器的源码目录
# 但更可靠的方法是直接构建整个仓库，并指定二进制文件路径。

# 编译 Anki Sync Server
# 注意：ankitects/anki 仓库中同步服务器的源码在 rslib/syncv3/
# 但二进制文件名称是 anki-sync-server。
# 这里依赖 Cargo 识别根目录下的 Cargo.toml
RUN cargo build --release --locked --bin anki-sync-server

# 最终运行镜像
FROM debian:bookworm-slim

# 安装 Protobuf 运行时库和证书
RUN apt-get update && apt-get install -y libprotobuf-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /ankisyncdir

# 从构建阶段复制编译好的二进制文件
# **这是最终修正：使用 /app 路径**
COPY --from=builder /app/target/release/anki-sync-server /usr/local/bin/anki-sync-server

# 暴露端口
EXPOSE 8080

# 默认启动命令
CMD ["anki-sync-server"]
