#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/get-standalone-vscode.sh)

vscode_dir_path="$HOME/apps/vscode"
vscode_archive_url='https://code.visualstudio.com/sha/download?build=stable&os=linux-x64'
vscode_archive_path="$vscode_dir_path/archive.tar.gz"
vscode_launcher_path="$HOME/.local/share/applications/vscode.desktop"

if [ -d "$vscode_dir_path" ]; then
    echo "Directory $vscode_dir_path already exists. Installed app version:"
    "$vscode_dir_path/VSCode-linux-x64/bin/code" -v

    vscode_old_dir_path="$vscode_dir_path-old-$(date +%Y-%m-%d-%H%M%S)"
    echo "Moving $vscode_dir_path to $vscode_old_dir_path"
    mv "$vscode_dir_path" "$vscode_old_dir_path"
fi

mkdir -p "$vscode_dir_path"

echo "Downloading $vscode_archive_url to $vscode_archive_path"
curl -SLo "$vscode_archive_path" "$vscode_archive_url"

echo "Extracting $vscode_archive_path to $vscode_dir_path"
tar -xzf "$vscode_archive_path" -C "$vscode_dir_path"

echo 'Installed app version:'
"$vscode_dir_path/VSCode-linux-x64/bin/code" -v

echo "Creating launcher file in $vscode_launcher_path"
cat << EOF >> "$vscode_launcher_path"
[Desktop Entry]
Name=Visual Studio Code
Exec=$vscode_dir_path/VSCode-linux-x64/code %f
Comment=Visual Studio Code
Terminal=false
Icon=$vscode_dir_path/VSCode-linux-x64/resources/app/resources/linux/code.png
Type=Application
EOF

echo 'Installation completed successfully'
