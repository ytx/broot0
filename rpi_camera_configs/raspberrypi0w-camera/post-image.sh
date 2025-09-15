#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

for arg in "$@"
do
	case "${arg}" in
		--add-miniuart-bt-overlay)
		if ! grep -qE '^dtoverlay=.*-bt$' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtoverlay=miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
			echo "dtoverlay=miniuart-bt" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
		fi
		;;
		--aarch64)
		# Run a 64bits kernel (armv8)
		sed -e '/^kernel=/s,=.*,=kernel8.img,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		if ! grep -qE '^arm_64bit=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'arm_64bit=1' to config.txt (forcing the kernel to boot in 64bit mode)"
			echo "arm_64bit=1" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
		fi
		;;
		--gpu_mem_256=*|--gpu_mem_512=*|--gpu_mem_1024=*)
		# Only apply to specific memory sizes
		gpu_mem="${arg:2}"
		echo "Adding '${gpu_mem}' to config.txt"
		echo "${gpu_mem}" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
		;;
		--gpu_mem=*)
		gpu_mem="${arg:2}"
		echo "Adding '${gpu_mem}' to config.txt"
		echo "${gpu_mem}" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
		;;
	esac
done

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"