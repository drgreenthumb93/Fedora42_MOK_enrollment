# Fedora42_MOK_enrollment
Quick guide for secure boot with fedora and NVIDIA graphics cards

This is a quick tutorial for removing the current MOK and installing a new one. If you're struggling getting secure boot to work with NVIDIA cards, this is your guide!

1. Frist you need to remove the current MOK with ```sudo mokutil --reset```. This will reset all MOK certificates.
2. Then remove all NVIDIA drivers
``sudo dnf remove *nvidia*``
``sudo akmods --force
sudo dracut --force
sudo reboot``
3. If you used the NVIDIA installer, do it with ```sudo /usr/bin/nvidia-uninstall```
4. 
