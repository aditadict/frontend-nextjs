# ===========================================
# Atlas Digitalize - Docker Deployment Guide
# Using Caddy for automatic SSL & reverse proxy
# ===========================================

## 🚀 Quick Start

### Prerequisites
- Ubuntu 20.04+ VPS (minimum 1GB RAM, 2GB recommended)
- Domain name (atlasdigitalize.com) pointing to your VPS IP
- SSH access to your VPS

### Files Overview
```
├── Dockerfile              # Multi-stage production build
├── docker-compose.yml      # Production config (port 9004)
├── docker-compose.dev.yml  # Development/testing
├── Caddyfile               # Caddy reverse proxy config
├── .dockerignore           # Optimize build context
├── .env.example            # Environment template
└── scripts/
    ├── setup-vps.sh        # Initial VPS setup (Docker + Caddy)
    ├── setup-caddy.sh      # Add site to Caddy config
    ├── start.sh            # Start application
    ├── stop.sh             # Stop application
    ├── deploy.sh           # Zero-downtime deployment
    ├── logs.sh             # View logs
    └── backup.sh           # Backup configs
```

---

## 📋 Step-by-Step Deployment

### Step 1: Prepare Your VPS

SSH into your VPS:
```bash
ssh root@your-vps-ip
```

### Step 2: Upload Your Project

**Option A: Using Git**
```bash
cd /opt
git clone <your-repo-url> atlas-frontend
cd atlas-frontend
```

**Option B: Using SCP (from your local machine)**
```bash
scp -r ./frontend-nextjs root@your-vps-ip:/opt/atlas-frontend
```

### Step 3: Run VPS Setup (if Docker/Caddy not installed)

```bash
cd /opt/atlas-frontend
chmod +x scripts/*.sh
sudo ./scripts/setup-vps.sh
```

This installs:
- Docker & Docker Compose
- Caddy web server
- Firewall (UFW) + Fail2ban
- System optimizations

### Step 4: Configure Environment

```bash
cp .env.example .env
nano .env
```

Set your backend URL:
```env
NEXT_PUBLIC_BACKEND_URL=https://api.atlasdigitalize.com
DOMAIN=atlasdigitalize.com
```

### Step 5: Point Your Domain

Add DNS A records:
- `atlasdigitalize.com` → Your VPS IP
- `www.atlasdigitalize.com` → Your VPS IP

### Step 6: Add Caddy Configuration

Since you already have Caddy running, add the site config:

```bash
# Interactive setup
./scripts/setup-caddy.sh

# OR manually append to Caddyfile
sudo cat Caddyfile >> /etc/caddy/Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

### Step 7: Start the Application

```bash
./scripts/start.sh
```

### Step 8: Verify Deployment

```bash
# Check container status
docker compose ps

# Test locally
curl http://localhost:9004

# Test live site
curl -I https://atlasdigitalize.com
```

---

## 🔄 Updating Your Application

```bash
cd /opt/atlas-frontend
./scripts/deploy.sh
```

This will:
1. Pull latest code (if using git)
2. Build new Docker image
3. Deploy with minimal downtime
4. Clean up old images
5. Verify site is accessible

---

## 🔧 Common Commands

```bash
# Start application
./scripts/start.sh

# Stop application
./scripts/stop.sh

# View logs
./scripts/logs.sh

# Deploy updates
./scripts/deploy.sh

# Rebuild from scratch
docker compose down
docker compose up -d --build

# Check Caddy status
sudo systemctl status caddy

# View Caddy logs
sudo journalctl -u caddy -f

# Reload Caddy config
sudo systemctl reload caddy
```

---

## 📊 Why Caddy?

| Feature | Benefit |
|---------|---------|
| **Automatic HTTPS** | SSL certificates obtained & renewed automatically |
| **Zero Config SSL** | No certbot, no cron jobs, no manual renewal |
| **HTTP/2 & HTTP/3** | Fastest protocols enabled by default |
| **Simple Config** | ~50 lines vs 200+ for Nginx |
| **Built-in Compression** | Gzip & Zstd automatic |

---

## 🔒 Security Features

- **HTTPS enforced** - All HTTP redirects to HTTPS
- **HSTS enabled** - 1 year with preload
- **Security headers** - X-Frame-Options, CSP, etc.
- **Automatic SSL renewal** - Caddy handles everything
- **Fail2ban** - Blocks brute force attempts
- **UFW firewall** - Only ports 22, 80, 443 open

---

## 🐛 Troubleshooting

### Container won't start
```bash
docker compose logs nextjs
docker compose build --no-cache nextjs
```

### 502 Bad Gateway
```bash
# Check if container is running on port 9004
docker compose ps
curl http://localhost:9004

# Restart container
docker compose restart nextjs
```

### Caddy issues
```bash
# Validate config
sudo caddy validate --config /etc/caddy/Caddyfile

# Check logs
sudo journalctl -u caddy --since "10 minutes ago"

# Restart Caddy
sudo systemctl restart caddy
```

### SSL certificate issues
```bash
# Caddy auto-obtains certs - just make sure:
# 1. Domain DNS points to this server
# 2. Ports 80 and 443 are open
# 3. Caddy is running

sudo ufw status
sudo systemctl status caddy
```

---

## 📁 Architecture

```
Internet
    │
    ▼
┌─────────────┐
│   Caddy     │  Port 80/443 (SSL termination)
│  (Host)     │  Auto HTTPS, compression, caching
└─────────────┘
    │
    ▼ localhost:9004
┌─────────────┐
│  Next.js    │  Docker container
│  (Docker)   │  Internal port 3000 → Host 9004
└─────────────┘
    │
    ▼
┌─────────────┐
│  Backend    │  api.atlasdigitalize.com
│  (Laravel)  │
└─────────────┘
```

---

## 🎯 Production Checklist

- [ ] Domain DNS configured (A records)
- [ ] .env file created with correct values
- [ ] Caddy config added and validated
- [ ] Docker container running on port 9004
- [ ] Site loads over HTTPS
- [ ] Backend API accessible
- [ ] Images loading correctly
