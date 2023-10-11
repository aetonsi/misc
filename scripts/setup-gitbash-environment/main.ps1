#Requires -Version 5.1
#Requires -RunAsAdministrator

# Set-ExecutionPolicy Bypass -Scope Process -Force; irm 'https://cdn.jsdelivr.net/gh/aetonsi/misc/scripts/setup-gitbash-environment/main.ps1' > ($f="$([System.IO.Path]::GetTempPath())$([guid]::NewGuid()).ps1"); & ((get-process -id $PID).path) -f $f


Write-Output 'Installing Chocolatey'

# The following command has been taken from https://chocolatey.org/install
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Write-Output 'Installing required Chocolatey packages'

choco install -y gsudo git

Write-Output 'Configuring Git environment variables'

# This is needed to be able to use the Windows OpenSSH Authentication Agent with
# Git; basically it tells Git to always use the SSH executable from Windows
# instead of the one from Git Bash
[Environment]::SetEnvironmentVariable('GIT_SSH', "$((Get-Command ssh).Source)", [System.EnvironmentVariableTarget]::User)

Write-Output 'Running embedded Bash script'

Write-Output @'
#!/bin/bash

set -e

if grep 'HISTCONTROL=' ~/.bashrc >/dev/null 2>&1; then
    echo 'Skipping HISTCONTROL setting in ~/.bashrc as it seems already present'
else
    echo 'Adding HISTCONTROL setting to ~/.bashrc'
    test -f ~/.bashrc || echo '#!/bin/bash' > ~/.bashrc
    echo HISTCONTROL=ignoreboth >> ~/.bashrc
fi

file='/mingw64/share/git/completion/git-prompt.sh'
if [ -f "$file" ]; then
    echo "Moving $file to $file.old"
    mv "$file" "$file.old"
else
    echo "Skipping renaming $file as $file.old already exists"
fi

echo 'Downloading .minttyrc'
curl -o ~/.minttyrc https://raw.githubusercontent.com/dmotte/misc/main/scripts/setup-gitbash-environment/.minttyrc

echo 'Setting Git options'
/mingw64/bin/git config --global core.autocrlf input

# Please ignore this line; the last line of the embedded Bash script must be a comment to avoid https://stackoverflow.com/a/36218934
'@ | & "$env:ProgramFiles\Git\usr\bin\bash.exe" --login -s

Write-Output 'Setup completed successfully'
