# Fedora42_MOK_enrollment
Quick guide for secure boot with fedora and NVIDIA graphics cards

This is a quick tutorial for removing the current MOK and installing a new one. If you're struggling getting secure boot to work with NVIDIA cards, this is your guide!

1. Frist you need to remove the current MOK with ```sudo mokutil --reset```. This will reset all MOK certificates.
2. Then remove all NVIDIA drivers
```
sudo dnf remove *nvidia*
sudo akmods --force
sudo dracut --force
sudo reboot
```
3. If you used the NVIDIA installer, do it with ```sudo /usr/bin/nvidia-uninstall```
4. Reinstall the driver package ```sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm```
5. Install NVIDIA drivers ```sudo dnf install akmod-nvidia```, optional for CUDA and ML ```sudo dnf install xorg-x11-drv-nvidia-cuda```
6. Now create a directory for the certificate enrollment: ```mkdir -p ~/mok``` ```cd ~/mok```
7. Create the certificate with openssl ```openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=Fedora MOK NVIDIA/"```
8. Import the fresh certificate: ```sudo mokutil --import MOK.der``` -> you will be asked for a password
9. Reboot the system, you will be asked by the MOK-Manager to enroll or boot, select "ENROLL". Enter the password you've created with ```mokutil```, hit "continue" and reboot; the enrolled key is now active.
10. Find the built NVIDIA-Kernel module with ```find /lib/modules/$(uname -r)/ -name 'nvidia*.ko*'```<br/>
It should look like this <br/>
```/lib/modules/6.15.9-201.fc42.x86_64/kernel/drivers/platform/x86/nvidia-wmi-ec-backlight.ko.xz```<br/>
```/lib/modules/6.15.9-201.fc42.x86_64/extra/nvidia/nvidia-drm.ko```<br/>
```/lib/modules/6.15.9-201.fc42.x86_64/extra/nvidia/nvidia.ko```<br/>
```/lib/modules/6.15.9-201.fc42.x86_64/extra/nvidia/nvidia-modeset.ko```<br/>
```/lib/modules/6.15.9-201.fc42.x86_64/extra/nvidia/nvidia-peermem.ko```<br/>
```/lib/modules/6.15.9-201.fc42.x86_64/extra/nvidia/nvidia-uvm.ko```<br/>
12. Sign the modules with your created key:
```
find /usr/lib/modules/$(uname -r)/extra/nvidia/ -name "*.ko*" | while read mod; do
  sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 ~/mok/MOK.priv ~/mok/MOK.der "$mod"
done
```
13. Rebuild initramfs with ```dracut --force``` and finally reboot.
14. After rebooting, check if your driver is loaded correctly with ```nvidia-smi```
15. Double-check if the modules are loaded ```lsmod | grep nvidia```, it should look like this </br>
```
nvidia_drm
nvidia_modeset
nvidia_uvm
nvidia
```
16. Run the script after a new kernel update.

