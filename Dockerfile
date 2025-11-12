# Dockerfile

# 使用 Rust 官方的构建镜像作为基础
FROM rust:latest AS builder

# 安装 Protobuf 编译器，Anki Sync Server 构建所需
# 对于 Debian/Ubuntu 系：
RUN apt-get update && apt-get install -y protobuf-compiler

# 设置工作目录
WORKDIR /app

# 克隆 Anki 官方仓库（这里只克隆同步服务器部分，减少不必要的文件）
# 注意：这里我们克隆整个仓库，然后在构建脚本中切换到 sync_server 子目录
# 也可以只克隆 sync_server 子目录，但可能会有版本问题，这里更通用
RUN git clone https://github.com/ankitects/anki.git .

# 构建 Anki Sync Server
# 使用 --locked 确保使用 Cargo.lock 中的精确依赖版本
# --release 构建优化版本
# --bin anki-sync-server 指定要构建的二进制文件
# --target 会由 buildx 自动设置
# RUN cargo build --release --locked --bin anki-sync-server --target ${TARGETPLATFORM}

# 最终运行镜像
FROM debian:bookworm-slim

# 安装 Protobuf 运行时库
RUN apt-get update && apt-get install -y libprotobuf-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /ankisyncdir

# 从构建阶段复制编译好的二进制文件
# 注意：这里假设构建出的可执行文件名为 anki-sync-server，位于 target/release/
COPY --from=builder /app/target/release/anki-sync-server /usr/local/bin/anki-sync-server

# 暴露端口
EXPOSE 8080

# 默认启动命令
# 通过环境变量传递用户凭证
CMD ["anki-sync-server"]

# 示例环境变量定义（请在 Docker Compose 或 k8s 中设置）
# ENV SYNC_USER1="user:password"
