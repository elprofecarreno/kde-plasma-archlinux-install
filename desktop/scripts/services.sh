echo "Enable NetworkManager Services"
systemctl enable NetworkManager
echo "Enable sddm Services"
systemctl enable sddm
echo "Enable sshd Services"
systemctl enable sshd
echo "Enable ufw Services"
systemctl enable ufw
systemctl start ufw
ufw enable
echo "Enable bluetooth Services"
systemctl enable bluetooth
echo "Enable docker Services"
sudo systemctl enable docker.service
echo "Enable PipeWire Services (System-wide templates)"
# Habilitar los sockets a nivel de usuario global para nuevos usuarios
systemctl --global enable pipewire.socket
systemctl --global enable pipewire-pulse.socket
systemctl --global enable wireplumber.service
echo "Enable system-timesyncd Services"
systemctl enable systemd-timesyncd