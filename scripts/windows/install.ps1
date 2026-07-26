# ============================================
# INSTALADOR PORTFOLIO WORDPRESS
# GitHub: RicardoRiveraSalas/PortafolioWP
# ============================================

Write-Host "============================================" -ForegroundColor Green
Write-Host "   INSTALADOR PORTFOLIO WORDPRESS" -ForegroundColor Green
Write-Host "   GitHub: RicardoRiveraSalas/PortafolioWP" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Verificar Git
Write-Host "[1/6] Verificando Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Git no encontrado" }
    Write-Host "       Git encontrado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Git no esta instalado." -ForegroundColor Red
    Write-Host "Descarga desde: https://git-scm.com/download/win" -ForegroundColor Cyan
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar Docker
Write-Host ""
Write-Host "[2/6] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Docker no encontrado" }
    Write-Host "       Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker no esta instalado." -ForegroundColor Red
    Write-Host "Descarga desde: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar Docker ejecutandose
Write-Host ""
Write-Host "[3/6] Verificando Docker Desktop..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Docker no corriendo" }
    Write-Host "       Docker esta ejecutandose." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker Desktop no esta ejecutandose." -ForegroundColor Red
    Write-Host "Abre Docker Desktop y espera a que este listo." -ForegroundColor Cyan
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Clonar repositorio
Write-Host ""
Write-Host "[4/6] Clonando repositorio PortafolioWP..." -ForegroundColor Yellow
if (Test-Path "wordpress\.git") {
    Write-Host "       Repositorio ya existe, actualizando..." -ForegroundColor Cyan
    Set-Location wordpress
    git pull
    Set-Location ..
} else {
    if (Test-Path "wordpress") {
        Remove-Item -Recurse -Force wordpress
    }
    git clone https://github.com/RicardoRiveraSalas/PortafolioWP.git wordpress
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Error al clonar repositorio." -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}
Write-Host "       Repositorio clonado correctamente." -ForegroundColor Green

# Levantar servicios
Write-Host ""
Write-Host "[5/6] Levantando servicios Docker..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Error al levantar servicios." -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar contenedores
Write-Host ""
Write-Host "[6/6] Verificando contenedores..." -ForegroundColor Yellow
Start-Sleep -Seconds 15
docker compose ps

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   INSTALACION COMPLETADA" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "   Repositorio: PortafolioWP" -ForegroundColor Cyan
Write-Host ""
Write-Host "   WordPress:    http://localhost:8080" -ForegroundColor Cyan
Write-Host "   phpMyAdmin:   http://localhost:8081" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Base de datos:" -ForegroundColor Yellow
Write-Host "     Usuario:     wpuser"
Write-Host "     Contrasena:  wp123456"
Write-Host "     Base:        wordpress"
Write-Host ""
Write-Host "   Siguiente paso:" -ForegroundColor Yellow
Write-Host "     1. Abre http://localhost:8080"
Write-Host "     2. Sigue el instalador de WordPress"
Write-Host "     3. Configura tu portafolio"
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Read-Host "Presiona Enter para continuar"
