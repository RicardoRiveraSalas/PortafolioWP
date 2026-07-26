#!/bin/bash
# ============================================
# INSTALADOR PORTFOLIO WORDPRESS - LINUX
# GitHub: RicardoRiveraSalas/PortafolioWP
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   INSTALADOR PORTFOLIO WORDPRESS${NC}"
echo -e "${GREEN}   GitHub: RicardoRiveraSalas/PortafolioWP${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Verificar Git
echo -e "${YELLOW}[1/6] Verificando Git...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${RED}ERROR: Git no esta instalado.${NC}"
    echo "Instala con: sudo apt install git (Ubuntu/Debian)"
    echo "             sudo dnf install git (Fedora)"
    echo "             sudo pacman -S git (Arch)"
    exit 1
fi
echo -e "${GREEN}       Git encontrado: $(git --version)${NC}"

# Verificar Docker
echo ""
echo -e "${YELLOW}[2/6] Verificando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker no esta instalado.${NC}"
    echo "Instala desde: https://docs.docker.com/engine/install/"
    exit 1
fi
echo -e "${GREEN}       Docker encontrado: $(docker --version)${NC}"

# Verificar Docker corriendo
echo ""
echo -e "${YELLOW}[3/6] Verificando Docker...${NC}"
if ! docker info &> /dev/null; then
    echo -e "${RED}ERROR: Docker no esta ejecutandose.${NC}"
    echo "Ejecuta: sudo systemctl start docker"
    echo "O: sudo service docker start"
    exit 1
fi
echo -e "${GREEN}       Docker esta ejecutandose.${NC}"

# Verificar docker-compose
echo ""
echo -e "${YELLOW}[4/6] Verificando docker-compose...${NC}"
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}ERROR: docker-compose no disponible.${NC}"
    echo "Instala con: sudo apt install docker-compose-plugin"
    exit 1
fi
echo -e "${GREEN}       docker-compose encontrado.${NC}"

# Clonar repositorio
echo ""
echo -e "${YELLOW}[5/6] Clonando repositorio PortafolioWP...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

if [ -d "wordpress/.git" ]; then
    echo -e "${CYAN}       Repositorio ya existe, actualizando...${NC}"
    cd wordpress
    git pull
    cd ..
else
    rm -rf wordpress
    git clone https://github.com/RicardoRiveraSalas/PortafolioWP.git wordpress
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Error al clonar el repositorio.${NC}"
    exit 1
fi
echo -e "${GREEN}       Repositorio clonado correctamente.${NC}"

# Levantar servicios
echo ""
echo -e "${YELLOW}[6/6] Levantando servicios Docker...${NC}"
$COMPOSE_CMD up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Error al levantar los servicios.${NC}"
    exit 1
fi

# Verificar contenedores
echo ""
echo -e "${YELLOW}Verificando contenedores...${NC}"
sleep 15
$COMPOSE_CMD ps

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   INSTALACION COMPLETADA${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${CYAN}   Repositorio: PortafolioWP${NC}"
echo ""
echo -e "${CYAN}   WordPress:    http://localhost:8080${NC}"
echo -e "${CYAN}   phpMyAdmin:   http://localhost:8081${NC}"
echo ""
echo -e "${YELLOW}   Base de datos:${NC}"
echo "     Usuario:     wpuser"
echo "     Contrasena:  wp123456"
echo "     Base:        wordpress"
echo ""
echo -e "${YELLOW}   Siguiente paso:${NC}"
echo "     1. Abre http://localhost:8080"
echo "     2. Sigue el instalador de WordPress"
echo "     3. Configura tu portafolio"
echo ""
echo -e "${GREEN}============================================${NC}"
