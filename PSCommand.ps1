- hosts: windows
  tasks:
    - name: Test Powershell
      win_shell: |
        Get-command
      Register: clc
