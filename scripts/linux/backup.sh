#!/bin/bash
# ============================================
# RESPALDO WORDPRESS - LINUX
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   RESPALDO PORTFOLIO WORDPRESS${NC}"
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

# Crear carpeta de respaldo con fecha
FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/backup_$FECHA"

echo -e "${YELLOW}Creando respaldo en: $BACKUP_DIR${NC}"
echo ""

mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}[1/4] Respaldando base de datos...${NC}"
docker exec wordpress_db mysqldump -u root -proot123 wordpress > "$BACKUP_DIR/wordpress_db.sql"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}       Base de datos respaldada.${NC}"
else
    echo -e "${RED}       ERROR al respaldar base de datos.${NC}"
fi

echo -e "${YELLOW}[2/4] Respaldando archivos de WordPress...${NC}"
docker exec wordpress_app tar -czf /tmp/wp_backup.tar.gz -C /var/www/html .
docker cp wordpress_app:/tmp/wp_backup.tar.gz "$BACKUP_DIR/wordpress_files.tar.gz"
echo -e "${GREEN}       Archivos respaldados.${NC}"

echo -e "${YELLOW}[3/4] Respaldando configuracion...${NC}"
cp .env "$BACKUP_DIR/" 2>/dev/null
cp docker-compose.yml "$BACKUP_DIR/" 2>/dev/null
echo -e "${GREEN}       Configuracion respaldada.${NC}"

echo -e "${YELLOW}[4/4] Guardando info del repositorio...${NC}"
cd wordpress
git remote -v > "$BACKUP_DIR/repo_info.txt"
git log --oneline -5 >> "$BACKUP_DIR/repo_info.txt"
git status >> "$BACKUP_DIR/repo_info.txt"
cd ..
echo -e "${GREEN}       Info del repositorio guardada.${NC}"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   RESPALDO COMPLETADO${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "   Ubicacion: $BACKUP_DIR"
echo ""
echo "   Archivos generados:"
echo "     - wordpress_db.sql (base de datos)"
echo "     - wordpress_files.tar.gz (archivos WP)"
echo "     - .env (configuracion)"
echo "     - docker-compose.yml"
echo "     - repo_info.txt (info del repo)"
echo -e "${GREEN}============================================${NC}"
echo ""
