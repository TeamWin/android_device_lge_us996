# Release name
PRODUCT_RELEASE_NAME := us996

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit from our custom product configuration
$(call inherit-product, vendor/omni/config/common.mk)

PRODUCT_PACKAGES += \
	charger_res_images \
	charger

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := us996
PRODUCT_MODEL := LG-US996
PRODUCT_NAME := omni_us996
PRODUCT_BRAND := lge
PRODUCT_MANUFACTURER := LGE
PRODUCT_COPY_FILES += device/lge/$(PRODUCT_DEVICE)/recovery.fstab:recovery/root/etc/twrp.flags
PRODUCT_COPY_FILES += system/timezone/output_data/iana/tzdata:recovery/root/system/usr/share/zoneinfo/tzdata
PRODUCT_COPY_FILES += $(LOCAL_PATH)/recovery/libcryptfs_hw.so:system/vendor/lib64/libcryptfs_hw.so
