profile_docker() {
	title="Docker"
	desc="Alpine with docker, SSH and other utils preinstalled."
	profile_base
	profile_abbrev="docker"
	image_ext="iso"
	arch="aarch64 x86 x86_64 ppc64le riscv64 s390x"
	output_format="iso"
	kernel_addons="xtables-addons"
	apks="$apks \
		docker docker-bash-completion docker-compose docker-compose-bash-completion docker-cli-compose \
		bash-completion procps util-linux readline findutils sed coreutils sudo e2fsprogs lvm2"
	apkovl="genapkovl-docker.sh"
}
