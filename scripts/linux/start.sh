#!/bin/bash
# ============================================
# INICIAR SERVICIOS - LINUX
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   INICIANDO SERVICIOS WORDPRESS${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

$COMPOSE_CMD up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: No se pudieron iniciar los servicios.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Servicios iniciados correctamente.${NC}"
echo ""
echo -e "${YELLOW}WordPress:    http://localhost:8080${NC}"
echo -e "${YELLOW}phpMyAdmin:   http://localhost:8081${NC}"
echo ""
