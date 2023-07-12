#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-omnia
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-omnia
  SECTION:=utils
  CATEGORY:=ROOter
   SUBMENU:=Router Specific
  TITLE:=support for Omnia
  PKGARCH:=all
endef

define Package/ext-omnia/description
  Helper scripts to add Omnia
endef


define Build/Compile
endef

define Package/ext-omnia/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ext-omnia))
