#!/bin/bash
# Description: Setup for running PasswordLessSSH.ps1
# INTENDED TO BE RUN FROM THE DIRECTORY "Windows_SSH"

# Builds container
sudo docker build -t powershell-ntlm Docker_files/PasswordLessSSH-Container
# Get the current users .ssh directory
user_ssh=~/.ssh

# Runs the container
sudo docker run -it --mount type=bind,src=$(pwd),dst=/tmp2 --mount type=bind,src=$user_ssh,dst=/ssh powershell-ntlm /tmp2/windows_ssh.ps1