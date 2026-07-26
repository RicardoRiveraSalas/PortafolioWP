#!/bin/bash
# ============================================
# ACTUALIZAR PORTFOLIO - LINUX
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   ACTUALIZANDO PORTFOLIO${NC}"
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

echo -e "${YELLOW}[1/3] Actualizando repositorio...${NC}"
if [ -d "wordpress/.git" ]; then
    cd wordpress
    git pull
    cd ..
else
    echo -e "${RED}No se encontro el repositorio. Ejecuta install.sh primero.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[2/3] Reiniciando WordPress...${NC}"
$COMPOSE_CMD restart wordpress

echo ""
echo -e "${YELLOW}[3/3] Verificando...${NC}"
$COMPOSE_CMD ps

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   ACTUALIZACION COMPLETADA${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
