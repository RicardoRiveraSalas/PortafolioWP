#!/bin/bash
# ============================================
# DESINSTALAR WORDPRESS DOCKER - LINUX
# ============================================

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo -e "${RED}============================================${NC}"
echo -e "${RED}   DESINSTALAR WORDPRESS DOCKER${NC}"
echo -e "${RED}============================================${NC}"
echo ""
echo -e "${YELLOW}   Esto eliminara:${NC}"
echo "     - Todos los contenedores"
echo "     - Volumenes de base de datos"
echo "     - Redes Docker"
echo ""
echo -e "${YELLOW}   NOTA: Los archivos de WordPress y respaldos${NC}"
echo "         NO se eliminan."
echo ""
read -p "¿Continuar? (s/n): " CONFIRMAR
if [ "$CONFIRMAR" != "s" ] && [ "$CONFIRMAR" != "S" ]; then
    echo "Operacion cancelada."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

echo ""
echo -e "${YELLOW}[1/3] Deteniendo contenedores...${NC}"
$COMPOSE_CMD down -v

echo -e "${YELLOW}[2/3] Eliminando imagenes...${NC}"
docker rmi wordpress:latest 2>/dev/null
docker rmi mysql:8.0 2>/dev/null
docker rmi phpmyadmin/phpmyadmin 2>/dev/null

echo -e "${YELLOW}[3/3] Limpiando...${NC}"
docker system prune -f 2>/dev/null

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   DESINSTALACION COMPLETADA${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
