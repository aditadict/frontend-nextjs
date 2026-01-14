#!/bin/bash

# ===========================================
# Atlas Digitalize - Stop Application
# ===========================================

set -e

echo "Stopping Atlas Digitalize..."

docker compose down

echo "Application stopped."
