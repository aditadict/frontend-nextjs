#!/bin/bash

# ===========================================
# Atlas Digitalize - View Logs
# ===========================================

# Default to following all logs
SERVICE=${1:-""}

if [ -n "$SERVICE" ]; then
    docker compose logs -f "$SERVICE"
else
    docker compose logs -f
fi
