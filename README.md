# WordPress Docker - PortafolioWP

Entorno Docker completo para el portafolio WordPress de Ricardo Rivera Salas.

## Descripcion

Proyecto Docker que configura automaticamente:
- **WordPress** - Sistema de gestion de contenido
- **MySQL 8.0** - Base de datos
- **phpMyAdmin** - Administrador de base de datos web

## Requisitos Previos

### Windows
| Software | Enlace de descarga |
|----------|-------------------|
| Docker Desktop | https://www.docker.com/products/docker-desktop/ |
| Git | https://git-scm.com/download/win |

### Linux (Ubuntu/Debian)
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Instalar Git
sudo apt install -y git

# Cerrar y abrir terminal para aplicar cambios de grupo
```

### Linux (Fedora)
```bash
# Instalar Docker
sudo dnf install -y docker docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Instalar Git
sudo dnf install -y git
```

## Instalacion

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

## URLs de Acceso

| Servicio | URL | Descripcion |
|----------|-----|-------------|
| WordPress | http://localhost:8080 | Panel principal |
| phpMyAdmin | http://localhost:8081 | Administrador BD |

## Credenciales Base de datos

| Campo | Valor |
|-------|-------|
| Usuario MySQL | `wpuser` |
| Contrasena | `wp123456` |
| Base de datos | `wordpress` |
| Root password | `root123` |

> **Nota:** Estas credenciales son para entorno de desarrollo. Cambia las contraseñas en el archivo `.env` antes de produccion.

## Comandos Disponibles

### Scripts por Plataforma

| Comando | Windows (.bat) | Linux (.sh) | Descripcion |
|---------|---------------|-------------|-------------|
| Instalar | `scripts\windows\install.bat` | `./scripts/linux/install.sh` | Clona repo + instala todo |
| Iniciar | `scripts\windows\start.bat` | `./scripts/linux/start.sh` | Inicia servicios Docker |
| Detener | `scripts\windows\stop.bat` | `./scripts/linux/stop.sh` | Detiene servicios |
| Actualizar | `scripts\windows\update.bat` | `./scripts/linux/update.sh` | Actualiza repo + reinicia |
| Estado | `scripts\windows\status.bat` | `./scripts/linux/status.sh` | Muestra estado y recursos |
| Respaldar | `scripts\windows\backup.bat` | `./scripts/linux/backup.sh` | Crea respaldo completo |
| Desinstalar | `scripts\windows\uninstall.bat` | `./scripts/linux/uninstall.sh` | Elimina todo |

### Comandos Docker Manuales

```bash
# Iniciar servicios
docker compose up -d

# Detener servicios
docker compose down

# Ver estado
docker compose ps

# Ver logs
docker compose logs -f

# Reiniciar un servicio
docker compose restart wordpress

# Acceder a terminal WordPress
docker exec -it wordpress_app bash

# Acceder a terminal MySQL
docker exec -it wordpress_db mysql -u wpuser -p
```

## Siguiente Paso despues de Instalar

1. Abre http://localhost:8080
2. Selecciona idioma (Español)
3. Configura WordPress:
   - **Titulo del sitio:** Portafolio WP
   - **Usuario:** tu usuario
   - **Contrasena:** tu contrasena
   - **Email:** tu email
4. Haz clic en "Instalar WordPress"
5. Instala un tema de portafolio desde **Apariencia > Temas**

### Temas Recomendados para Portafolio

- **Astra** - Ligero y personalizable
- **GeneratePress** - Rapido y responsive
- **OceanWP** - Multip proposito
- **flavor** - Enfocado en portafolios

## Estructura del Proyecto

```
wordpress-docker/
├── .env                        # Variables de entorno (no subir a git)
├── .gitignore                  # Archivos ignorados por git
├── docker-compose.yml          # Configuracion Docker
├── wordpress/                  # Repositorio PortafolioWP (clonado)
│   └── .git/
├── scripts/
│   ├── windows/                # Scripts para Windows
│   │   ├── install.bat
│   │   ├── install.ps1
│   │   ├── start.bat
│   │   ├── stop.bat
│   │   ├── update.bat
│   │   ├── status.bat
│   │   ├── backup.bat
│   │   └── uninstall.bat
│   └── linux/                  # Scripts para Linux
│       ├── install.sh
│       ├── start.sh
│       ├── stop.sh
│       ├── update.sh
│       ├── status.sh
│       ├── backup.sh
│       └── uninstall.sh
├── backups/                    # Respaldos (generados)
└── README.md                   # Esta documentacion
```

## Respaldos

Ejecuta el script de backup para crear un respaldo completo:
- Base de datos SQL
- Archivos de WordPress
- Configuracion del proyecto
- Info del repositorio Git

Los respaldos se guardan en la carpeta `backups/` con formato: `backup_YYYYMMDD_HHMMSS/`

## Solucion de Problemas

### Docker no inicia
- **Windows:** Abre Docker Desktop y espera 2-3 minutos
- **Linux:** `sudo systemctl start docker`

### Puerto 8080 ocupado
Cambia el puerto en `docker-compose.yml`:
```yaml
ports:
  - "9090:80"  # Cambia 8080 por otro puerto
```

### Error de permisos (Linux)
```bash
sudo usermod -aG docker $USER
# Cerrar y abrir sesion
```

### WordPress no conecta a BD
```bash
docker compose down -v
docker compose up -d
```

### Limpiar todo y empezar de cero
```bash
docker compose down -v --rmi all
rm -rf wordpress/*
./scripts/linux/install.sh  # o install.bat en Windows
```

## Desarrollo

### Personalizar WordPress

Los archivos de WordPress se encuentran en `wordpress/`. Puedes:
- Instalar plugins desde el panel
- Subir temas personalizados
- Editar archivos directamente

### Cambiar version de PHP/MySQL

Edita `docker-compose.yml`:
```yaml
services:
  db:
    image: mysql:8.0  # Cambia版本
  wordpress:
    image: wordpress:6.4-php8.2  # Cambia版本
```

## Licencia

MIT License - Copyright (c) 2026 Ricardo Rivera Salas

## GitHub

https://github.com/RicardoRiveraSalas/PortafolioWP
