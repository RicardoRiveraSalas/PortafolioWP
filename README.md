# ============================================
# GUIA DE INSTALACION PORTFOLIO WORDPRESS
# GitHub: RicardoRiveraSalas/PortafolioWP
# ============================================

## Requisitos Previos

### Windows
1. **Docker Desktop** - https://www.docker.com/products/docker-desktop/
2. **Git** - https://git-scm.com/download/win

### Linux
1. **Docker Engine** - https://docs.docker.com/engine/install/
2. **Git** - `sudo apt install git` (Ubuntu/Debian)
3. **Docker Compose** - `sudo apt install docker-compose-plugin`

## Instalacion Rapida

### Windows

**Opcion 1: Script BAT (doble clic)**
```
Doble clic en scripts\windows\install.bat
```

**Opcion 2: PowerShell**
```powershell
.\scripts\windows\install.ps1
```

### Linux

```bash
cd scripts/linux
sudo ./install.sh
```

### Manual (cualquier SO)

```bash
git clone https://github.com/RicardoRiveraSalas/PortafolioWP.git wordpress
docker compose up -d
```

## Comandos Disponibles

### Windows (`scripts/windows/`)

| Archivo | Descripcion |
|---------|-------------|
| `install.bat` | Clona repo + instala todo |
| `install.ps1` | Instalador PowerShell |
| `start.bat` | Inicia los servicios |
| `stop.bat` | Detiene los servicios |
| `update.bat` | Actualiza repo + reinicia |
| `status.bat` | Muestra estado y recursos |
| `backup.bat` | Crea respaldo completo |
| `uninstall.bat` | Elimina todo |

### Linux (`scripts/linux/`)

| Archivo | Descripcion |
|---------|-------------|
| `install.sh` | Clona repo + instala todo |
| `start.sh` | Inicia los servicios |
| `stop.sh` | Detiene los servicios |
| `update.sh` | Actualiza repo + reinicia |
| `status.sh` | Muestra estado y recursos |
| `backup.sh` | Crea respaldo completo |
| `uninstall.sh` | Elimina todo |

## URLs de Acceso

| Servicio | URL |
|----------|-----|
| WordPress | http://localhost:8080 |
| phpMyAdmin | http://localhost:8081 |

## Credenciales Base de datos

| Campo | Valor |
|-------|-------|
| Usuario MySQL | wpuser |
| Contrasena | wp123456 |
| Base de datos | wordpress |
| Root password | root123 |

## Siguiente Paso despues de Instalar

1. Abre http://localhost:8080
2. Selecciona idioma (Español)
3. Configura:
   - Titulo del sitio: "Portafolio WP"
   - Usuario: tu usuario
   - Contrasena: tu contrasena
   - Email: tu email
4. Haz clic en "Instalar WordPress"
5. Instala un tema de portafolio desde Apariencia > Temas

## Solucion de Problemas

### Docker no inicia
- **Windows:** Abre Docker Desktop y espera 2-3 minutos
- **Linux:** `sudo systemctl start docker`

### Puerto 8080 ocupado
Cambia el puerto en `docker-compose.yml`:
```yaml
ports:
  - "9090:80"
```

### Error de permisos (Linux)
Ejecuta con `sudo` o agrega tu usuario al grupo docker:
```bash
sudo usermod -aG docker $USER
```

### WordPress no conecta a BD
```bash
docker compose down -v
docker compose up -d
```

### Actualizar el repositorio
```bash
# Windows
scripts\windows\update.bat

# Linux
./scripts/linux/update.sh
```

## Estructura del Proyecto

```
wordpress-docker/
├── .env                        # Variables de entorno
├── docker-compose.yml          # Configuracion Docker
├── wordpress/                  # Repositorio PortafolioWP (clonado)
│   └── .git/
├── scripts/
│   ├── windows/
│   │   ├── install.bat         # Instalador Windows
│   │   ├── install.ps1         # Instalador PowerShell
│   │   ├── start.bat           # Iniciar servicios
│   │   ├── stop.bat            # Detener servicios
│   │   ├── update.bat          # Actualizar repositorio
│   │   ├── status.bat          # Ver estado
│   │   ├── backup.bat          # Respaldar datos
│   │   └── uninstall.bat       # Desinstalar todo
│   └── linux/
│       ├── install.sh          # Instalador Linux
│       ├── start.sh            # Iniciar servicios
│       ├── stop.sh             # Detener servicios
│       ├── update.sh           # Actualizar repositorio
│       ├── status.sh           # Ver estado
│       ├── backup.sh           # Respaldar datos
│       └── uninstall.sh        # Desinstalar todo
└── README.md                   # Esta guia
```

## Respaldos

Ejecuta el script de backup para crear un respaldo completo:
- Base de datos SQL
- Archivos de WordPress
- Configuracion del proyecto
- Info del repositorio Git

Los respaldos se guardan en la carpeta `backups/`.

## GitHub Repository

https://github.com/RicardoRiveraSalas/PortafolioWP
