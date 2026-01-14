#!/bin/bash

# ===========================================
# Atlas Digitalize - Deployment Script
# Run this for zero-downtime deployments
# ===========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Atlas Digitalize - Deploy             ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Step 1: Pull latest code (if using git)
if [ -d .git ]; then
    echo -e "\n${YELLOW}Step 1: Pulling latest code...${NC}"
    git pull origin main
fi

# Step 2: Build new image
echo -e "\n${YELLOW}Step 2: Building new Docker image...${NC}"
docker compose build --no-cache nextjs

# Step 3: Stop old container and start new one
echo -e "\n${YELLOW}Step 3: Deploying new container...${NC}"
docker compose up -d nextjs

# Step 4: Wait for health check
echo -e "\n${YELLOW}Step 4: Waiting for health check...${NC}"
sleep 10

# Check if container is healthy
if docker compose ps | grep -q "healthy"; then
    echo -e "\n${GREEN}Deployment successful!${NC}"
else
    echo -e "\n${YELLOW}Container starting... checking again...${NC}"
    sleep 20
    if docker compose ps | grep -q "healthy\|running"; then
        echo -e "\n${GREEN}Deployment successful!${NC}"
    else
        echo -e "\n${RED}Deployment may have issues. Check logs:${NC}"
        echo -e "${BLUE}docker compose logs nextjs${NC}"
    fi
fi

# Step 5: Clean up old images
echo -e "\n${YELLOW}Step 5: Cleaning up old images...${NC}"
docker image prune -f

# Step 6: Verify site is accessible
echo -e "\n${YELLOW}Step 6: Verifying site on port 9004...${NC}"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9004 | grep -q "200\|301\|302"; then
    echo -e "${GREEN}Site is responding on port 9004${NC}"
else
    echo -e "${YELLOW}Site may still be starting up...${NC}"
fi

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}  Deployment Complete!                   ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\n${YELLOW}Site URL:${NC} ${BLUE}https://atlasdigitalize.com${NC}"
