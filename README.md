# LlamaFactory Multi-Arch Docker Build (ARM64 & AMD64)

[![Build Middleware](https://github.com/kingfs/llamafactory-build/actions/workflows/build-middleware.yml/badge.svg)](https://github.com/kingfs/llamafactory-build/actions/workflows/build-middleware.yml)
[![Build App](https://github.com/kingfs/llamafactory-build/actions/workflows/build-app.yml/badge.svg)](https://github.com/kingfs/llamafactory-build/actions/workflows/build-app.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/kingfs/llamafactory)

## 📖 简介 (Introduction)

本项目旨在为 **NVIDIA ARM64 架构设备** (如 DGX GH200, Grace Hopper, Jetson Orin 等) 提供开箱即用的 [LlamaFactory](https://github.com/hiyouga/LlamaFactory) Docker 镜像。

官方 LlamaFactory 镜像目前主要支持 AMD64 (x86_64)。在 ARM64 平台上，由于 `flash-attention`、`bitsandbytes` 和 `deepspeed` 等核心库缺乏预编译的 Wheel 包，用户往往需要花费数小时进行本地编译，且极易遇到环境依赖问题。

本项目利用 GitHub Actions 实现 **全自动、透明化** 的多架构构建（AMD64 + ARM64），并推送到 Docker Hub 供社区使用。

## 🏗️ 构建架构 (Architecture)

为了应对 ARM64 编译耗时过长的问题，本项目采用 **分层构建策略 (Multi-Stage Build)**：

1.  **Middleware Image (中间件镜像)**: `kingfs/llamafactory:middleware`
    *   **更新频率**: 低 (仅在 CUDA 或 核心算子库版本更新时触发)
    *   **基础**: `nvcr.io/nvidia/pytorch:25.06-py3` (CUDA 12.4 compatible)
    *   **包含**: 预编译好的 FlashAttention-2, DeepSpeed, Bitsandbytes 等重型依赖。
    *   **目的**: 作为基础设施，避免每次代码更新都重新编译 CUDA 算子。

2.  **Application Image (应用镜像)**: `kingfs/llamafactory:latest`
    *   **更新频率**: 高 (跟随 LlamaFactory 官方代码更新)
    *   **基础**: `kingfs/llamafactory:middleware`
    *   **包含**: LlamaFactory 源代码, HuggingFace 相关 Python 依赖。
    *   **目的**: 提供即拉即用的最终用户环境。

## 🚀 快速开始 (Quick Start)

### 1. 拉取镜像

支持自动识别架构（无需指定 tag，Docker 会自动拉取 arm64 或 amd64 版本）：

```bash
docker pull kingfs/llamafactory:latest
```

### 2. 启动容器 (以单机微调为例)

```bash
docker run --gpus all \
    --shm-size 16G \
    -v /path/to/your/data:/app/data \
    -v /path/to/your/output:/app/output \
    -it kingfs/llamafactory:latest \
    bash
```

### 3. 验证环境

进入容器后，验证核心库是否安装成功：

```bash
python -c "import torch; print('Torch:', torch.__version__, torch.cuda.is_available()); \
           import flash_attn; print('FlashAttn:', flash_attn.__version__); \
           import bitsandbytes; print('BnB:', bitsandbytes.__version__)"
```

## 🛠️ 构建细节 (Build Details)

### 依赖版本矩阵

| 组件 | 版本 (Target) | 备注 |
| :--- | :--- | :--- |
| **Base Image** | `nvcr.io/nvidia/pytorch:25.06-py3` | 包含 CUDA 12.4 工具链 |
| **PyTorch** | 2.4.0+ |随 NGC 镜像版本 |
| **FlashAttention** | v2.8.3 | 源码编译安装 |
| **DeepSpeed** | Latest | 预编译 Ops |
| **Bitsandbytes** | Latest | 源码编译/跨平台 Wheel |

### 本地自行构建 (可选)

如果你需要在本地 DGX 设备上自行构建，可以参考以下命令：

```bash
# 1. 构建中间件层 (耗时较长)
docker build -t local/llamafactory:middleware -f docker/Dockerfile.middleware .

# 2. 构建应用层 (耗时短)
docker build -t local/llamafactory:latest \
    --build-arg BASE_IMAGE=local/llamafactory:middleware \
    -f docker/Dockerfile.app .
```

## 📝 贡献与支持

*   本镜像非官方镜像，主要为了解决 ARM64 社区痛点。
*   核心代码版权归 [LlamaFactory](https://github.com/hiyouga/LlamaFactory) 团队所有。
*   基础镜像版权归 NVIDIA Corporation 所有。

如有构建问题，请提交 Issue。
