DESCRIPTION = "Basic Utils for Evogro Images"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    bash \
    e2fsprogs \
    file \
    findutils \
    grep \
    sed \
    sudo \
    openssh \
    openssh-sftp-server \
    tzdata \
    curl \
    util-linux-mountpoint \
    util-linux-hwclock \
    iw \
    hostapd \
    dnsmasq \
    iptables \
    networkmanager \
"

# kernel modules for balenaFin
RDEPENDS_${PN} += " \
    kernel-module-cdc-acm \
    kernel-module-uvcvideo \
    kernel-module-xt-tcpudp \
    kernel-module-xt-redirect \
"
