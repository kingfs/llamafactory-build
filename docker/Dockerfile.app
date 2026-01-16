# 接收构建参数，默认指向我们构建好的 middleware
ARG BASE_IMAGE=kingfs/llamafactory:middleware
FROM ${BASE_IMAGE}

WORKDIR /app

# 1. 设置环境变量
ENV PYTHONPATH="/app:${PYTHONPATH}"

# 2. 拷贝辅助脚本
COPY scripts/clean_requirements.py /tmp/clean_requirements.py

# 3. 拉取 LlamaFactory 代码并处理依赖
# 使用 git clone 保证获取最新代码，也可以通过 ARG 控制 commit hash
RUN git clone https://github.com/hiyouga/LlamaFactory.git . && \
    # 清理 requirements.txt，移除已编译的 heavy 库
    python /tmp/clean_requirements.py requirements.txt requirements_clean.txt && \
    # 安装剩余依赖
    pip install --no-cache-dir -r requirements_clean.txt && \
    # 安装 LlamaFactory 本身
    pip install -e .[metrics,deepspeed,bitsandbytes] && \
    # 清理缓存
    rm -rf /root/.cache/pip /tmp/*

# 4. 设置入口
# 允许用户直接传参给 llamafactory-cli
ENTRYPOINT ["llamafactory-cli"]
CMD ["help"]