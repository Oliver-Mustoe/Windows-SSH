FROM rockylinux:8
# Updates and install needed package
RUN dnf makecache --refresh -y
RUN dnf install -y epel-release
RUN dnf makecache --refresh -y
RUN dnf -y install gssntlmssp
# Install Powershell
RUN  rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
RUN dnf makecache -y
RUN dnf -y install powershell
# Install needed powershell library
SHELL [ "/usr/bin/pwsh", "-command" ]
RUN Install-Module -Name PSWSMan -Force
RUN Install-WSMan
# Creates needed directory structure
RUN mkdir tmp2 ssh
# ENTRYPOINT [ "/usr/bin/pwsh" ]