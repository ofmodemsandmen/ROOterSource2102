#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-viper
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-viper
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +ext-rooter-basic +extramenu +bwallocate +ext-domain +ext-zerotier \
		+luci-app-ddns +ddns-scripts +pingtest \
		+luci-app-rootervpn +ext-wireguard \
		+bwmon +464xlat \
		+ext-theme +luci-theme-argon +argon-config +ext-login \
		+luci-theme-tomato +ext-material \
		+ca-bundle +ca-certificates \
		+luci-app-ksmbd +usb-storage \
		+ext-p910nd +kmod-sched-cake +luci-app-nft-qos \
		+ext-command +ext-speedtest \
		+openvpn-easy-rsa +openvpn-openssl \
		+ext-extra +luci-app-hotspot +luci-app-wol +luci-app-guestwifi \
		+usbmuxd +libusbmuxd-utils +libimobiledevice-utils +kmod-usb-net-ipheth \
		+nano +picocom +wpad +wget +qfirehose 
  TITLE:=ROOter support w/o MWan3 for 16meg and larger routers
  PKGARCH:=all
endef

define Package/ext-viper/description
  Helper scripts to enable ROOter w/o MWan3 on 16meg and larger routers
endef


define Build/Compile
endef

$(eval $(call BuildPackage,ext-viper))
