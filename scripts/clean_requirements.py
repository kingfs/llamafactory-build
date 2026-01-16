import sys

# 我们在 middleware 镜像中已经手动编译安装的库
# 必须小写，匹配 pip freeze 的格式
PRE_INSTALLED_PACKAGES = {
    "flash-attn",
    "deepspeed",
    "bitsandbytes",
    "auto-gptq",   # 视情况而定，如果太难编译也可以放这
    "xformers"
}

def clean_requirements(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    cleaned_lines = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#'):
            cleaned_lines.append(line)
            continue
        
        # 简单的包名提取逻辑 (适用于大多数 requirements.txt)
        # 例如: "flash-attn>=2.5.0" -> "flash-attn"
        pkg_name = line.split('>')[0].split('<')[0].split('=')[0].strip().lower()
        
        if pkg_name in PRE_INSTALLED_PACKAGES:
            print(f"Skipping pre-installed package: {line}")
            continue
            
        cleaned_lines.append(line)

    with open(output_file, 'w') as f:
        f.write('\n'.join(cleaned_lines))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python clean_requirements.py <input> <output>")
        sys.exit(1)
    
    clean_requirements(sys.argv[1], sys.argv[2])
