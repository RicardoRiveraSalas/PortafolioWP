#!/bin/bash
# ============================================
# ESTADO DE SERVICIOS - LINUX
# ============================================

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   ESTADO DE LOS SERVICIOS${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

echo -e "${YELLOW}Contenedores:${NC}"
echo "----------------------------------------"
$COMPOSE_CMD ps
echo ""

echo -e "${YELLOW}Uso de recursos:${NC}"
echo "----------------------------------------"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null
echo ""

echo -e "${YELLOW}Volumenes:${NC}"
echo "----------------------------------------"
docker volume ls | grep -i wordpress 2>/dev/null
echo ""

echo -e "${YELLOW}Red:${NC}"
echo "----------------------------------------"
docker network ls | grep -i wpnet 2>/dev/null
echo ""
