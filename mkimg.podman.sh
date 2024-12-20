profile_podman() {
	title="Podman"
	desc="Alpine with docker, SSH and other utils preinstalled."
	profile_base
	profile_abbrev="podman"
	image_ext="iso"
	arch="aarch64 x86 x86_64 ppc64le riscv64 s390x"
	output_format="iso"
	kernel_addons="xtables-addons"
	apks="$apks \
		podman \
		bash-completion procps util-linux readline findutils sed coreutils sudo e2fsprogs lvm2"
	apkovl="genapkovl-podman.sh"
	hostname="alpdock"
}
