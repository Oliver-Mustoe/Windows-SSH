# OpenSSH for Windows
## Project Description
Automate the installation of OpenSSH for a Windows host from a Linux environment, and optionally, setup passwordless SSH on the Windows host

## Prerequisites
1. A sudo user with an RSA key pair (run ```ssh-keygen -t rsa```)
2. Docker installed
3. A Windows host & an administrative user on it
4. Windows installation on the ```C:``` Drive (if not the case, requires edits to "windows_ssh.ps1")

## Installation
1. Clone this github repository with ```git clone https://github.com/Oliver-Mustoe/Windows-SSH.git```
2. ***FROM INSIDE THE DIRECTORY "Windows_SSH"*** Run the bash script with ```bash docker_run.sh``` OR make the script executable and run it with ```chmod +x docker_run.sh && ./docker_run.sh```
3. Follow along with the prompts :)
4. Use the commands to make sure the SSH agent is functioning:
```bash
eval $(ssh-agent)
ssh-add -t 20000 # 2000 can be changed to any number you want
```

# Manual-Installation
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