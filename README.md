# OpenSSH for Windows
1. [Project Description](#project-description)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Manual-Installation](#manual-installation)
5. [Troubleshooting](#troubleshooting)
6. [Sources](https://github.com/Oliver-Mustoe/Windows-SSH/blob/main/Sources.md)
## Project Description
Automate the installation of OpenSSH for a Windows host from a Linux environment, and optionally, setup passwordless SSH on the Windows host for ONE Linux host

**TESTED ON:**
- Windows Server 2019

## Prerequisites
1. A sudo user with an RSA key pair (run ```ssh-keygen -t rsa```)
2. Docker installed
3. A Windows host & an administrative user on it
4. Windows installation on the ```C:``` Drive [(if not the case, requires edits to "windows_ssh.ps1")](#Troubleshooting)

## Installation
1. Clone this github repository with ```git clone https://github.com/Oliver-Mustoe/Windows-SSH.git```
2. ***FROM INSIDE THE DIRECTORY "Windows_SSH"*** Run the bash script with ```bash docker_run.sh``` OR make the script executable and run it with ```chmod +x docker_run.sh && ./docker_run.sh```
3. Follow along with the prompts :)
4. Use the commands to make sure the SSH agent is functioning:
```bash
eval $(ssh-agent)
ssh-add -t 20000 # 2000 can be changed to any number you want
```

## Manual Installation
For Whatever reason, the following can be used to manually complete the commands performed in "docker_run.sh" (Same pre-reqs apply)
1. Clone this github repository with ```git clone https://github.com/Oliver-Mustoe/Windows-SSH.git```
2. ***FROM INSIDE THE DIRECTORY "Windows_SSH":***
```bash
# Builds container
sudo docker build -t {INSERT_CONTAINER_NAME_HERE} {PATH_TO_"PasswordLessSSH-Container"_DIR}
# Runs the container
sudo docker run -it --mount type=bind,src={PATH_TO_"windows_ssh.ps1"},dst=/tmp2 --mount type=bind,src={PATH_TO_RSA_KEY_PAIR},dst=/ssh powershell-ntlm /tmp2/windows_ssh.ps1
```
3. Use the commands to make sure the SSH agent is functioning:
```bash
eval $(ssh-agent)
ssh-add -t 20000 # 2000 can be changed to any number you want
```

## Troubleshooting
* **Non-C Drive Windows installation**
	* The following line in "windows_ssh.ps1" will need to be changed for your installation (rest of script makes use of enviro variables, so no changes should need to be made there in theory)
```powershell
Set-SCPItem -ComputerName $remote_ip -Credential $cred -Path "ssh/id_rsa.pub" -Destination "C:\ProgramData\ssh" -Force -Verbose
# Change here^     to     here^
```
* **Multiple Linux hosts need passwordless SSH onto Windows target**
	* In this scenario, base script can be ran and for anymore Linux hosts that need access their RSA public key will need to be copied over to the target and APPENDED to the "administrators_authorized_keys" file.
* **Problems with downloading OpenSSH onto the target/Out of date OpenSSH**
	* Because the package is grabbed directly from Github, it may be required in the future to update the link to the package. To do so, update the following line in "windows_ssh.ps1" via checking these [OpenSSH releases](https://github.com/PowerShell/Win32-OpenSSH/releases):
```powershell
$repo="https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.1.0.0p1-Beta/OpenSSH-Win64.zip"
```
