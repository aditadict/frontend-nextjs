#!/bin/bash

# ===========================================
# Atlas Digitalize - Setup Caddy Config
# Adds the site to your existing Caddy setup
# ===========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default Caddy config location
CADDY_CONFIG="/etc/caddy/Caddyfile"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Atlas Digitalize - Caddy Setup        ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Check if Caddyfile exists in project
if [ ! -f "Caddyfile" ]; then
    echo -e "${RED}Caddyfile not found in current directory${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Your Caddyfile configuration:${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
cat Caddyfile
echo -e "${BLUE}----------------------------------------${NC}"

echo -e "\n${YELLOW}Options to add this configuration:${NC}"
echo -e "1. Append to existing Caddyfile"
echo -e "2. Show command to manually add"
echo -e "3. Exit"

read -p "Choose option (1-3): " option

case $option in
    1)
        echo -e "\n${YELLOW}Backing up existing Caddyfile...${NC}"
        cp $CADDY_CONFIG ${CADDY_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)
        
        echo -e "\n${YELLOW}Appending configuration...${NC}"
        echo "" >> $CADDY_CONFIG
        echo "# Atlas Digitalize Frontend - Added $(date)" >> $CADDY_CONFIG
        cat Caddyfile >> $CADDY_CONFIG
        
        echo -e "\n${YELLOW}Validating Caddy configuration...${NC}"
        if caddy validate --config $CADDY_CONFIG; then
            echo -e "\n${YELLOW}Reloading Caddy...${NC}"
            systemctl reload caddy
            echo -e "\n${GREEN}Caddy configuration updated successfully!${NC}"
        else
            echo -e "\n${RED}Configuration invalid! Restoring backup...${NC}"
            cp ${CADDY_CONFIG}.backup.* $CADDY_CONFIG
            systemctl reload caddy
            exit 1
        fi
        ;;
    2)
        echo -e "\n${YELLOW}Run these commands manually:${NC}"
        echo -e "${BLUE}sudo cp $CADDY_CONFIG ${CADDY_CONFIG}.backup${NC}"
        echo -e "${BLUE}sudo cat Caddyfile >> $CADDY_CONFIG${NC}"
        echo -e "${BLUE}sudo caddy validate --config $CADDY_CONFIG${NC}"
        echo -e "${BLUE}sudo systemctl reload caddy${NC}"
        ;;
    3)
        echo -e "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}  Setup Complete!                        ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\n${YELLOW}Your site will be available at:${NC}"
echo -e "${BLUE}https://atlasdigitalize.com${NC}"
echo -e "\n${YELLOW}SSL certificate will be obtained automatically by Caddy!${NC}"
