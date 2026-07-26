#!/bin/bash
# ============================================
# DETENER SERVICIOS - LINUX
# ============================================

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}   DETENIENDO SERVICIOS WORDPRESS${NC}"
echo -e "${YELLOW}============================================${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

$COMPOSE_CMD down

echo ""
echo -e "${GREEN}Servicios detenidos correctamente.${NC}"
echo ""
