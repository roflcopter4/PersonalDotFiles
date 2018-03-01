#!/bin/sh

./elevate.exe -c powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\\chocolatey\\bin"
./elevate.exe -c choco install python -y
./elevate.exe -c choco install python2 -y
./elevate.exe -c choco install git
./elevate.exe -c pip install neovim
