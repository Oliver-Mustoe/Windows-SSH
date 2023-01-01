# OpenSSH for Windows
## Project Description
Automate the installation of OpenSSH for Windows from a Linux environment, and optionally, setup passwordless SSH in the environment

## Prerequisites
1. A user with an RSA key pair (run ```ssh-keygen -t rsa```)
2. Docker installed

## Installation
1. Clone this github repository with ```git clone https://github.com/Oliver-Mustoe/Windows-SSH.git```
2. ***FROM INSIDE THE DIRECTORY "Windows_SSH"*** Run the bash script with ```sudo bash docker_run.sh```
3. Follow along with the prompts :)
4. Use the commands to make sure the SSH agent is functioning:
```bash
	eval $(ssh-agent)
	ssh-add -t 20000 # 2000 can be changed to any number you want
```