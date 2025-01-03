#!/bin/sh -e

version="3.21"

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	echo "usage: $0 hostname"
	exit 1
fi

cleanup() {
	rm -rf "$tmp"
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF

makefile root:root 0644 "$tmp"/etc/motd <<EOF

Welcome to Alpine with podman preinstalled (Live ISO)!

DHCP is enabled on eth0.
To configure other interfaces run 'setup-interfaces' and then 'service networking restart' to apply settings.

Type 'alpdock-run-portainer' to run Portainer.

EOF

mkdir -p "$tmp"/etc/network
makefile root:root 0644 "$tmp"/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
bash-completion
coreutils
podman
findutils
openssh
procps
readline
sed
sudo
util-linux
EOF

makefile root:root 0644 "$tmp"/etc/apk/repositories <<EOF
https://dl-cdn.alpinelinux.org/alpine/v${version}/main
https://dl-cdn.alpinelinux.org/alpine/v${version}/community
EOF

mkdir -p "$tmp"/etc/local.d
makefile root:root 0744 "$tmp"/etc/local.d/set_bash.start <<EOF
#!/bin/ash
sed -i 's|root:/bin/ash|root:/bin/bash|' /etc/passwd
EOF

makefile root:root 0744 "$tmp"/etc/local.d/add_user.start <<EOF
#!/bin/ash
user="linux"
echo -e "\$user\n\$user" | adduser \$user -s /bin/bash
mkdir /etc/sudoers.d
echo "\$user ALL=(ALL) ALL" > /etc/sudoers.d/\$user && chmod 0440 /etc/sudoers.d/\$user
# Podman rootless support
modprobe tun
echo tun >> /etc/modules
echo \$user:100000:65536 >> /etc/subuid
echo \$user:100000:65536 >> /etc/subgid
EOF

mkdir -p "$tmp"/usr/bin
makefile root:root 0755 "$tmp"/usr/bin/alpdock-run-portainer <<EOF
#!/bin/sh

podman volume create portainer_data
podman run \
	--detach \
	--volume=/var/run/podman/podman.sock:/var/run/docker.sock \
	--volume=portainer_data:/data \
	--publish=8000:8000 \
	--publish=9443:9443 \
	--restart=always \
	--name=portainer \
	portainer/portainer-ce:latest
EOF

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot
rc_add networking boot
rc_add local boot

rc_add podman default
rc_add sshd default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

tar -c -C "$tmp" etc usr| gzip -9n > $HOSTNAME.apkovl.tar.gz
