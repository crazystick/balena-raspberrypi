inherit kernel-resin

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_fincm3 = " \
	file://0004-mmc-pwrseq-Repurpose-for-Marvell-SD8777.patch \
	file://0005-balena-fin-wifi-sta-uap-mode.patch \
"

SRC_URI_append = " \
	file://0002-wireless-wext-Bring-back-ndo_do_ioctl-fallback.patch \
"

LINUX_VERSION = "4.19.118"
SRCREV = "fe2c7bf4cad4641dfb6f12712755515ab15815ca"

# These configs are probably already in the
# updated defconfig and should be removed
# from here
do_configure_prepend() {
#    kernel_configure_variable RTC_DRV_DS1307 m
#    kernel_configure_variable MWIFIEX m
     kernel_configure_variable IKCONFIG y
     kernel_configure_variable IKCONFIG_PROC y
     kernel_configure_variable PWRSEQ_SD8787 y
     kernel_configure_variable AUFS_FS y
     kernel_configure_variable AUFS_BRANCH_MAX_127=y
     kernel_configure_variable AUFS_SBILIST=y
     kernel_configure_variable AUFS_XATTR=y
     kernel_configure_variable AUFS_BR_HFSPLUS=y
     kernel_configure_variable AUFS_BDEV_LOOP=y
} 
