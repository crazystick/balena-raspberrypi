DESCRIPTION = "Development Utils for Evogro Images"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    e2fsprogs-resize2fs \
    screen \
    v4l-utils \
    usbutils \
    opkg \
    less \
    tcpdump \
    kernel-module-configs \
"
