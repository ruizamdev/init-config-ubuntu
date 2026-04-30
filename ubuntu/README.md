# init-config-ubuntu

Colección de scripts Bash para preparar un entorno de desarrollo en Ubuntu de forma rápida y consistente.

Incluye instalación de:

- Google Chrome
- Brave Browser
- Warp Terminal
- Visual Studio Code
- Vim con plugins base
- Node.js (vía `nvm`) y `pnpm`
- Docker Engine
- Oh My Zsh

## Requisitos

- Ubuntu o distribución basada en Ubuntu.
- Usuario con permisos de `sudo`.
- Conexión a Internet.

## Estructura del proyecto

- `install-all.sh`: orquestador maestro que ejecuta todos los scripts en orden.
- `scripts/`: scripts individuales de instalación.
- `templates/`: plantilla base (`run-step-pattern.sh`) para crear nuevos scripts con el mismo patrón visual y de manejo de errores.

## Uso rápido (todo el setup)

Desde la raíz del repositorio:

```bash
chmod +x install-all.sh
./install-all.sh
```

`install-all.sh` se detiene automáticamente si algún script falla (`set -euo pipefail`).

## Ejecutar un script individual

```bash
chmod +x ./scripts/install-vscode.sh
./scripts/install-vscode.sh
```

Reemplaza `install-vscode.sh` por cualquier script dentro de `scripts/`.

## Orden actual de ejecución en el script maestro

1. `install-chrome.sh`
2. `install-brave.sh`
3. `install-warp.sh`
4. `install-vscode.sh`
5. `vim-with-steroids.sh`
6. `install-nodejs.sh`
7. `install-docker.sh`
8. `install-oh-my-zsh.sh`

Nota: `install-oh-my-zsh.sh` va al final porque cambia el shell por defecto y puede interrumpir el flujo del script maestro.

## Patrón de salida y errores

Los scripts usan un patrón `run_step` con estas reglas:

- Salida silenciosa durante el procesamiento (logs internos).
- Mensaje visual de progreso por paso.
- Si un paso falla:
  - se muestra el detalle del error,
  - el script termina inmediatamente,
  - no continúa con los siguientes pasos.

## Recomendaciones después de ejecutar

- Cierra y abre sesión si cambiaste shell o grupos (por ejemplo, Docker).
- Verifica versiones instaladas:

```bash
code --version
node -v
docker --version
zsh --version
```

