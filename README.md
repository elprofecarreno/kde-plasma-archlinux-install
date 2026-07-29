# Instalación KDE Plasma en Arch Linux

Este repositorio contiene scripts para preparar un entorno de escritorio KDE Plasma en Arch Linux y configurar una clave GPG para KDE Wallet.

## Scripts incluidos

- `desktop/install.sh`: instala paquetes base, habilita servicios, instala aplicaciones Flatpak y permite seleccionar drivers GPU.
- `desktop/create-gpg.sh`: genera una clave GPG y asigna confianza total para evitar errores de KDE Wallet.

## Orden correcto de uso

1. Ejecuta primero `install.sh` como root.
2. Reinicia el sistema (el script lo hace al final).
3. Inicia sesión en KDE Plasma.
4. Ejecuta `create-gpg.sh` con tu usuario normal.

## Uso

### 1) Instalación base (root)

Desde la raíz del proyecto:

```bash
sudo bash desktop/install.sh
```

Durante la ejecución, selecciona el driver GPU cuando el menú interactivo lo solicite.

### 2) Crear clave GPG (usuario normal, dentro de KDE Plasma)

Después de iniciar sesión en KDE Plasma:

```bash
bash desktop/create-gpg.sh
```

El script pedirá:

- Nombre
- Correo electrónico
- Passphrase de la clave

Al finalizar, la clave quedará creada y con nivel de confianza total.

## Requisitos

- Arch Linux
- Conexión a internet
- Permisos de sudo para ejecutar el instalador
- Sesión iniciada en KDE Plasma para la creación de la clave GPG

## Nota

`install.sh` modifica `/etc/pacman.conf`, instala paquetes del sistema y habilita servicios. Revisa el script antes de ejecutarlo en entornos de producción.
