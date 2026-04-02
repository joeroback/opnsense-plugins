#!/bin/sh

set -e

ADGUARD_VERSION="v0.107.74"
ADGUARD_BIN="/usr/local/bin/adguardhome"
ADGUARD_BASE_URL="https://github.com/AdguardTeam/AdGuardHome/releases/download/${ADGUARD_VERSION}"

ARCH=$(uname -p)
case "${ARCH}" in
    amd64)
        ADGUARD_ARCH="amd64"
        ;;
    aarch64|arm64)
        ADGUARD_ARCH="arm64"
        ;;
    *)
        echo "Error: unsupported architecture: ${ARCH}" >&2
        exit 1
        ;;
esac

ADGUARD_TARBALL="AdGuardHome_freebsd_${ADGUARD_ARCH}.tar.gz"
ADGUARD_URL="${ADGUARD_BASE_URL}/${ADGUARD_TARBALL}"

TMPDIR=$(mktemp -d -t adguardhome)
trap "rm -rf ${TMPDIR}" EXIT

echo "Downloading AdGuard Home ${ADGUARD_VERSION} for freebsd/${ADGUARD_ARCH}..."
fetch -o "${TMPDIR}/${ADGUARD_TARBALL}" "${ADGUARD_URL}"

echo "Extracting AdGuard Home binary..."
tar -xzf "${TMPDIR}/${ADGUARD_TARBALL}" -C "${TMPDIR}" AdGuardHome/AdGuardHome

install -m 0755 -o root -g wheel "${TMPDIR}/AdGuardHome/AdGuardHome" "${ADGUARD_BIN}"

echo "AdGuard Home ${ADGUARD_VERSION} installed to ${ADGUARD_BIN}"
