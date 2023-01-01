# Description: Sets up passwordless SSH on a remote Windows system from a Linux environment

# Currently having issues with "acquiring creds with username only failed No credentials were supplied, or the credentials were unavailable or inaccessible SPNEGO cannot find mechanisms to negotiate For more information"

#Requires -RunAsAdministrator

# Global variables needed for SSHing
$LOCAL_USER=whoami
$LOCAL_IP=hostname -I
function main {
    # Add here a check for RSA keys

    Write-Output "[Obtaining credentials]..."
    # Setup remote host information that will be used later
    $remote_ip=Read-Host -Prompt "Enter IP/Hostname of Windows target to add SSH capabilites to"
    # Get the remote username
    $cred_user=Read-Host -Prompt "Credentials are required for access, please enter a administrative username on the target (For Domain account, enter: ‘Domain\User’)"

    # Create a session on a remote host
    #$cred=Get-Credential -Message "Credentials are required for access (For Domain account: ‘Domain\User’)."
    $cred=Get-Credential -UserName $cred_user
    $remote_session=New-PSSession -ComputerName $remote_ip -Credential $cred -Authentication Negotiate

    Write-Output "[Connecting to $remote_ip]..."
    InstallSSH -remote_session $remote_session

    # 12/31/22
    $user_choice=Read-Host -Prompt "Would you like to also enable passwordless SSH on $remote_ip? [y/N]"

    if ($user_choice.ToUpper() -eq "Y") {
        if (Test-Path ssh/id_rsa.pub) {
            Write-Output "[Setting up passwordless SSH on $remote_ip]"

            PasswordLessSSH -remote_session $remote_session

            Write-Output "Should now be able to connect with passwordless SSH after running the following:"
            Write-Output "eval \$(ssh-agent)"
            Write-Output "ssh-add -t 20000 # 2000 can be changed to any number you want"
            Write-Output "ssh $cred_user@$remote_ip"
        }
    }
    else {
        Write-Error -Message "NO SSH KEY ON HOST SYSTEM" -RecommendedAction "USE THE COMMAND 'ssh-keygen -t rsa' TO INSTALL SSH KEYS"
    }


    # 12/31/22
    Remove-PSSession $remote_session
}

function InstallSSH {
    param(
        $remote_session
    )

    Invoke-Command -Session $remote_session -ScriptBlock {
        # Install OpenSSH , does not install if ssh key
        # if (!(Test-Path "C:\ProgramData\ssh\ssh_host_rsa_key")) {
        if (!(Test-Path ($env:ProgramData + "\ssh\ssh_host_rsa_key"))) {
            # Grab a OpenSSH release
            $repo="https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.1.0.0p1-Beta/OpenSSH-Win64.zip"

            # Set the repo destination to the temp dir ($env:TMP) plus the zip name
            $repo_dest=$env:TMP + "\OpenSSH.zip"

            Write-Output "[Downloading SSH]..."
            # If this doesnt work, try Invoke-WebRequest
            Invoke-RestMethod -Uri $repo -OutFile $repo_dest
            
            Write-Output "[DONE]..."

            Write-Output "[Installing SSH]..."
            # Extract the SSH zip to the targets program files environmental variable ($env:)
            #Expand-Archive -Path $repo_dest -DestinationPath ($env:ProgramFiles)
            Expand-Archive -Path $repo_dest -DestinationPath $env:ProgramFiles
            
            # Set appropriate exection policy (scope is just process, so once powershell session is closed, will be reset to default)
            Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
            # Use the SSH install script ("". filename" can be used to run scripts in powershell and bash, who knew *shrug*)
            . ($env:ProgramFiles + "\OpenSSH-Win64\install-sshd.ps1")

            Write-Output "[DONE]..."

            Write-Output "[Setting needed Firewall rules]..."
            # Get the Windows product version, set certain firewall rules accordingly
            $windows_version=Out-String -InputObject (Get-ComputerInfo -Property "WindowsProductName").WindowsProductName
            if ($windows_version -contains "*Server*") {
                New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
            }
            else {
                netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22
            }

            Write-Output "[Cleaning up]..."
            # Cleanup temporary files
            Remove-item -Path $repo_dest -Force
        }
        
        Write-Output "[Starting SSH and setting parameters]..."
        # Start now and on startup
        Start-Service sshd
        Set-Service -Name sshd -StartupType Automatic
        
        # Change SSH shell to powershell
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name ConsolePrompting -Value $true
        New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name Defaultshell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
        
        # Test to ensure that SSH install is complete
        #if (Test-Path "C:\ProgramData\ssh\ssh_host_rsa_key") {
        if (Test-Path ($env:ProgramData + "\ssh\ssh_host_rsa_key")) {
            Write-Output "[SSH CONFIG COMPLETE]"
            $Global:remote_ssh_path=$env:ProgramData + "\ssh"
        }
        else {
            Write-Output "[SSH CONFIG FAILED :(]"
        }
    }
}

function PasswordLessSSH {
    param (
        $remote_session
    )
    
    Write-Output "[Copying public key over to target]..."
    # Copy public SSH key to Windows host
    Copy-Item -Path "ssh/id_rsa.pub" -Destination $Global:remote_ssh_path -ToSession $remote_session

    Write-Output "[Connecting to the target]..."
    Invoke-Command -Session $remote_session -ScriptBlock {
        Write-Output "[Creating a authorized key with permissions]..."
        # Copy the public key to programdata
        Get-Content ($Global:remote_ssh_path + "\id_rsa.pub") >> ($Global:remote_ssh_path + "\administrators_authorized_keys")

        # Set proper access control on the key
        icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
        icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /remove "NT AUTHORITY\Authenticated Users"
        Write-Output "[Restarting SSH and cleaning up]..."
        # Restart Services
        Restart-Service -Name sshd -Force

        Remove-Item -Path ($Global:remote_ssh_path + "\id_rsa.pub") -Force
    }

    Write-Output "[PASSWORDLESS SSH COMPLETE]..."
}
main