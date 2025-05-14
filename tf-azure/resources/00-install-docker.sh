#!/bin/bash

# Global variables
USER="azureuser"

print_line_break(){
  echo ' '
}

print_separator() {
  echo "------------------------------------------------"
}

print_log() {
  local str="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') -> $str"
}

print_separator
print_log "Starting Docker installation script..."
print_line_break

# ## 0. Install sudo and add user to sudoers
# apt-get update
# apt-get install -y sudo
# usermod -aG sudo $USER
# echo "Usuario $USER añadido a sudoers"

# Source: https://docs.docker.com/engine/install/debian/

## 1. Set up Docker's apt repository.

# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

## 2. Install the Docker packages.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

## 3. Post-install
sudo usermod -aG docker $USER

print_line_break
print_log "Finished Docker installation."
print_separator