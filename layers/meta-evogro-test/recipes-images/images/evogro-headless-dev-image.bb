SUMMARY = "Evogro headless image with extra dev tools"
DESCRIPTION = "no graphics support in this image"
LICENSE = "CLOSED"
inherit core-image

IMAGE_ROOTFS_SIZE ?= "2048"
IMAGE_ROOTFS_EXTRA_SPACE = "100000"

IMAGE_FEATURES += "ssh-server-openssh debug-tweaks package-management"

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    packagegroup-evogro-utils \
    packagegroup-evogro-dev-utils \
"

