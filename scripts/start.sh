#!/bin/bash

# ===========================================
# Atlas Digitalize - Start Application
# ===========================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting Atlas Digitalize...${NC}"

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${YELLOW}Warning: .env file not found. Using defaults.${NC}"
fi

# Build and start container
docker compose up -d --build

echo -e "\n${YELLOW}Waiting for container to be healthy...${NC}"
sleep 5

# Check status
if docker compose ps | grep -q "healthy\|running"; then
    echo -e "\n${GREEN}=========================================${NC}"
    echo -e "${GREEN}  Application started successfully!     ${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo -e "\n${YELLOW}Container:${NC} atlas-frontend"
    echo -e "${YELLOW}Port:${NC} 9004 (internal: 3000)"
    echo -e "\n${YELLOW}View logs:${NC} ${BLUE}./scripts/logs.sh${NC}"
    echo -e "${YELLOW}Site URL:${NC} ${BLUE}https://atlasdigitalize.com${NC}"
else
    echo -e "\n${YELLOW}Container is starting... Check logs:${NC}"
    echo -e "${BLUE}docker compose logs -f${NC}"
fi
