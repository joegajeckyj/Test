#!/bin/python

# Register the Microsoft RedHat repository
curl <a href="https://packages.microsoft.com/config/rhel/7/prod.repo" target="_blank">https://packages.microsoft.com/config/rhel/7/prod.repo</a> | sudo tee /etc/yum.repos.d/microsoft.repo
 
# Install PowerShell
sudo yum install -y powershell
