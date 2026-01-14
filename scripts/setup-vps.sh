#!/bin/bash

# ===========================================
# Atlas Digitalize - VPS Deployment Script
# For Ubuntu VPS with Caddy
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/opt/atlas-frontend"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Atlas Digitalize - VPS Setup Script   ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

echo -e "\n${YELLOW}Step 1: Updating system packages...${NC}"
apt update && apt upgrade -y

echo -e "\n${YELLOW}Step 2: Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    # Install Docker
    apt install -y ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add the repository to Apt sources
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    echo -e "${GREEN}Docker installed successfully!${NC}"
else
    echo -e "${GREEN}Docker is already installed${NC}"
fi

echo -e "\n${YELLOW}Step 3: Checking Caddy installation...${NC}"
if command -v caddy &> /dev/null; then
    echo -e "${GREEN}Caddy is already installed${NC}"
    caddy version
else
    echo -e "${YELLOW}Installing Caddy...${NC}"
    apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update
    apt install -y caddy
    systemctl enable caddy
    systemctl start caddy
    echo -e "${GREEN}Caddy installed successfully!${NC}"
fi

echo -e "\n${YELLOW}Step 4: Installing additional tools...${NC}"
apt install -y git htop ufw fail2ban

echo -e "\n${YELLOW}Step 5: Configuring firewall...${NC}"
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable
echo -e "${GREEN}Firewall configured!${NC}"

echo -e "\n${YELLOW}Step 6: Configuring fail2ban...${NC}"
systemctl enable fail2ban
systemctl start fail2ban
echo -e "${GREEN}Fail2ban configured!${NC}"

echo -e "\n${YELLOW}Step 7: Creating application directory...${NC}"
mkdir -p $APP_DIR
mkdir -p /var/log/caddy

echo -e "\n${YELLOW}Step 8: Setting up swap (for low memory VPS)...${NC}"
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    echo -e "${GREEN}2GB Swap created!${NC}"
else
    echo -e "${GREEN}Swap already exists${NC}"
fi

echo -e "\n${YELLOW}Step 9: Optimizing system for Docker...${NC}"
cat > /etc/sysctl.d/99-docker.conf << EOF
# Network performance
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.netdev_max_backlog = 5000

# File descriptors
fs.file-max = 2097152

# VM settings
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2
EOF

sysctl -p /etc/sysctl.d/99-docker.conf 2>/dev/null || true

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}  VPS Setup Complete!                    ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Copy project files to: ${BLUE}$APP_DIR${NC}"
echo -e "2. Create .env: ${BLUE}cp .env.example .env && nano .env${NC}"
echo -e "3. Add Caddy config: ${BLUE}./scripts/setup-caddy.sh${NC}"
echo -e "4. Start app: ${BLUE}./scripts/start.sh${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Copy your project files to: ${BLUE}$APP_DIR${NC}"
echo -e "2. Create .env file from .env.example"
echo -e "3. Run: ${BLUE}cd $APP_DIR && ./scripts/init-ssl.sh${NC}"
echo -e "4. Then: ${BLUE}./scripts/start.sh${NC}"
