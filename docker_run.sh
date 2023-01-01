#!/bin/bash
# Description: Setup for running PasswordLessSSH.ps1
# INTENDED TO BE RUN FROM THE DIRECTORY "Windows_SSH"

# Builds container
sudo docker build -t powershell-ntlm Docker_files\PasswordLessSSH-Container
# Runs the container
sudo docker run -it --mount type=bind,src=$(pwd),dst=/tmp2 --mount type=bind,src=~/.ssh/,dst=/ssh Powershell-NTLM /tmp2/windows_ssh.ps1