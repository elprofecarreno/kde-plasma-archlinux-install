# KDE Plasma setup on Arch Linux

This repository provides scripts to set up a KDE Plasma desktop environment on Arch Linux and configure a GPG key for KDE Wallet.

## Included scripts

- `desktop/install.sh`: installs base packages, enables services, installs Flatpak apps, and lets you choose GPU drivers.
- `desktop/create-gpg.sh`: generates a GPG key and assigns ultimate trust to avoid KDE Wallet trust errors.

## Correct execution order

1. Run `install.sh` first as root.
2. Reboot the system (the script does this at the end).
3. Log in to KDE Plasma.
4. Run `create-gpg.sh` as your regular user.

## Usage

### 1) Base installation (root)

From the project root:

```bash
sudo bash desktop/install.sh
```

During execution, select the GPU driver from the interactive menu.

### 2) Create GPG key (regular user, inside KDE Plasma)

After logging in to KDE Plasma:

```bash
bash desktop/create-gpg.sh
```

The script asks for:

- Name
- Email
- Key passphrase

When finished, the key is created and marked with ultimate trust.

## Requirements

- Arch Linux
- Internet connection
- Sudo permissions to run the installer
- Active KDE Plasma session for GPG key creation

## Note

`install.sh` updates `/etc/pacman.conf`, installs system packages, and enables services. Review the script before running it in production environments.
