#!/bin/bash

# ===========================================
# Atlas Digitalize - Backup Script
# ===========================================

set -e

BACKUP_DIR="/opt/atlas-backup"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Creating backup..."

# Backup SSL certificates
tar -czf $BACKUP_DIR/ssl_$DATE.tar.gz certbot/

# Backup nginx config
tar -czf $BACKUP_DIR/nginx_$DATE.tar.gz nginx/

# Backup environment
cp .env $BACKUP_DIR/.env_$DATE 2>/dev/null || true

echo "Backup complete: $BACKUP_DIR"

# Remove backups older than 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Old backups cleaned up"
