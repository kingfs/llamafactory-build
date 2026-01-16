# docker/Dockerfile.app
ARG BASE_IMAGE=kingfs/llamafactory:middleware
FROM ${BASE_IMAGE}

WORKDIR /app
ENV PYTHONPATH="/app:${PYTHONPATH}"

# 拷贝清理脚本
COPY scripts/clean_requirements.py /tmp/clean_requirements.py

# 获取源码并安装
# 注意：我们使用 uv 来加速依赖安装
RUN git clone https://github.com/hiyouga/LlamaFactory.git . && \
    # 1. 清理 requirements.txt，剔除已编译的库
    python /tmp/clean_requirements.py requirements.txt requirements_clean.txt && \
    # 2. 安装剩余依赖
    uv pip install -r requirements_clean.txt && \
    # 3. 安装 LlamaFactory (以 editable 模式，或直接安装)
    uv pip install -e .[metrics] && \
    # 清理
    rm -rf /root/.cache /tmp/* && \
    uv cache clean

ENTRYPOINT ["llamafactory-cli"]
CMD ["help"]