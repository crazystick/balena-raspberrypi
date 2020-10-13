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

do_configure_prepend() {
#    kernel_configure_variable RTC_DRV_DS1307 m
#    kernel_configure_variable MWIFIEX m
     kernel_configure_variable IKCONFIG m
     kernel_configure_variable IKCONFIG_PROC y
     kernel_configure_variable PWRSEQ_SD8787 y
} 
