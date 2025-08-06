#!/bin/bash

# colors 
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# MOK paths (adapt to yours)
KEY="$HOME/mok/MOK.priv"
CERT="$HOME/mok/MOK.der"

# path for signing tool
SIGN_TOOL="/usr/src/kernels/$(uname -r)/scripts/sign-file"

# directory with NVIDIA-modules
MODDIR="/lib/modules/$(uname -r)/extra/nvidia"

# Check: are key and cert existent
if [[ ! -f "$KEY" || ! -f "$CERT" ]]; then
  echo -e "${RED}[Error]${RESET} MOK-key or cert not found $KEY / $CERT"
  exit 1
fi

# Check: NVIDIA modules existent?
if [[ ! -d "$MODDIR" ]]; then
  echo -e "${RED}[Error]${RESET} NVIDIA-module directory not found: $MODDIR"
  exit 1
fi

echo -e "${GREEN}Signing NVIDIA-Kernelmodule...${RESET}"

# sign all .ko files
for mod in "$MODDIR"/*.ko; do
  echo " → Signing: $(basename "$mod")"
  sudo "$SIGN_TOOL" sha256 "$KEY" "$CERT" "$mod"
done

echo -e "${GREEN}Executing dracut...${RESET}"
sudo dracut --force

echo -e "${GREEN}[PASS]${RESET} All NVIDIA-Modules have been signed and initramfs updated."
echo -e " → You may reboot for the changes to be active."

exit 0
