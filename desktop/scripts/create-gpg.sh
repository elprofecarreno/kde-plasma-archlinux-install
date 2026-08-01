#!/bin/bash

# Solicitar datos por teclado
read -p "Introduce tu Nombre: " NOMBRE
read -p "Introduce tu Correo: " CORREO
read -s -p "Introduce tu contraseña ( passphrase ): " PASSPHRASE
echo ""

echo "==> Creando archivo de configuración temporal para GPG..."

cat > /tmp/gpg_batch_params <<EOF
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: $NOMBRE
Name-Email: $CORREO
Expire-Date: 0
Passphrase: $PASSPHRASE
%commit
EOF

echo "==> Generando la clave GPG..."
gpg --batch --passphrase "$PASSPHRASE" --generate-key /tmp/gpg_batch_params
rm /tmp/gpg_batch_params

# Asignar confianza total (Ultimate) automáticamente para evitar el Error 55 de KDE
echo "==> Configurando nivel de confianza total para la clave..."
KEY_ID=$(gpg --list-secret-keys --with-colons | grep "^sec" | tail -n 1 | cut -d':' -f5)
echo -e "5\ny\n" | gpg --command-fd 0 --edit-key "$KEY_ID" trust

echo "==> ¡Listo! Clave generada y con confianza total asignada."
echo "KDE Wallet ya debería funcionar sin errores."
