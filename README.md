# AlpDock
Alpine Linux with docker preinstalled (Live Image)

AlpDock includes only minimum amount of software needed to run Docker and SSH server.

### Root account
The root account does not have a password. To set it, type `passwd`.

### Networking
DHCP is enabled on eth0.  
To configure other interfaces run `setup-interfaces` and then `service networking restart` to apply settings.

### SSH
By default, it is not possible to log into the root account via ssh: use `linux` account (pass: `linux`)
