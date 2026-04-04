#!/bin/bash
# VPS 代理一键安装脚本
# 支持: Ubuntu 20.04+ / Debian 11+ / CentOS 8+

set -e

echo "========================================"
echo "  VPS 代理一键安装脚本"
echo "========================================"

# 检测系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "无法检测系统"
    exit 1
fi

echo "系统: $OS"

# 安装依赖
echo "[1/4] 安装依赖..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apt update && apt install -y curl wget
elif [ "$OS" = "centos" ]; then
    yum install -y curl wget
fi

# 安装 Docker
echo "[2/4] 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -sSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# 安装 Xray
echo "[3/4] 安装 Xray..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 配置
echo "[4/4] 配置 Xray..."
mkdir -p /usr/local/etc/xray
cat > /usr/local/etc/xray/config.json << 'EOF'
{
  "log": {"level": "warning"},
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {"clients": [{"id": "uuid-here", "flow": "xtls-rprx-vision"}]},
    "streamSettings": {"network": "tcp", "security": "tls", "tlsSettings": {"certificates": []}}
  }],
  "outbounds": [{"protocol": "freedom", "tag": "direct"}]
}
EOF

echo "========================================"
echo "  安装完成！"
echo "  配置文件: /usr/local/etc/xray/config.json"
echo "  启动命令: systemctl start xray"
echo "========================================"
