Start-Service sshd

Set-Service -Name sshd -StartupType Automatic

Set-Content -Path C:\ProgramData\ssh\administrators_authorized_keys -Value 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNBvNi+zXVPUJizYVLXaLSntIs37L5IwgXht47ozT9g pham@oma' -Encoding ascii

icacls.exe C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

Set-NetFirewallRule -Name OpenSSH-Server-In-TCP -Profile Any

