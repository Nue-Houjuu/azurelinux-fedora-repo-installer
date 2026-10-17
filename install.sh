#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FEDORA_RELEASE="${FEDORA_RELEASE:-43}"
REPO_DIR="/etc/yum.repos.d"
KEY_DIR="/etc/pki/rpm-gpg"
BACKUP_DIR="/var/backups/azurelinux-fedora-repo-installer/$(date +%Y%m%d-%H%M%S)"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
info() { printf '==> %s\n' "$*"; }

[[ $EUID -eq 0 ]] || die "Run with sudo: sudo $0"
[[ -r /etc/os-release ]] || die "Cannot read /etc/os-release."
# shellcheck disable=SC1091
source /etc/os-release

[[ "${ID:-}" == "azurelinux" ]] || die "This installer targets Azure Linux only; detected ID=${ID:-unknown}."
[[ "$FEDORA_RELEASE" =~ ^[0-9]+$ ]] || die "FEDORA_RELEASE must be a numeric Fedora release, e.g. 43."
command -v tdnf >/dev/null 2>&1 || command -v dnf5 >/dev/null 2>&1 || command -v dnf >/dev/null 2>&1 || die "No supported package manager found (tdnf, dnf5, or dnf)."

[[ -d "$SCRIPT_DIR/repos" ]] || die "Cannot find the repository's repos/ directory."
[[ -f "$SCRIPT_DIR/repos/fedora.repo" && -f "$SCRIPT_DIR/repos/fedora-updates.repo" ]] || die "Repository template files are missing."

info "Detected: ${PRETTY_NAME:-Azure Linux}"
info "Configuring Fedora $FEDORA_RELEASE repositories in disabled-by-default mode."
info "No packages will be installed by this script."

install -d -m 0755 "$REPO_DIR" "$KEY_DIR" "$BACKUP_DIR"

for name in azurelinux-fedora-experimental.repo azurelinux-fedora-updates-experimental.repo; do
    case "$name" in
        azurelinux-fedora-experimental.repo) src="$SCRIPT_DIR/repos/fedora.repo" ;;
        azurelinux-fedora-updates-experimental.repo) src="$SCRIPT_DIR/repos/fedora-updates.repo" ;;
    esac
    dst="$REPO_DIR/$name"
    if [[ -e "$dst" ]]; then
        cp -a -- "$dst" "$BACKUP_DIR/$name"
        info "Backed up existing $dst to $BACKUP_DIR/$name"
    fi
    tmp="$(mktemp "${REPO_DIR}/.${name}.XXXXXX")"
    sed "s/@FEDORA_RELEASE@/${FEDORA_RELEASE}/g" "$src" > "$tmp"
    chmod 0644 "$tmp"
    chown root:root "$tmp"
    mv -f -- "$tmp" "$dst"
done

info "Repository definitions installed. They remain disabled (enabled=0)."
if command -v tdnf >/dev/null 2>&1; then
    info "Review them with: tdnf repolist --all"
elif command -v dnf5 >/dev/null 2>&1; then
    info "Review them with: dnf5 repolist --all"
else
    info "Review them with: dnf repolist --all"
fi
info "Backup directory: $BACKUP_DIR"
printf '\nIMPORTANT: Adding repository files does not make Fedora packages compatible with Azure Linux.\n'
printf 'Use desktop-install.sh only in a disposable VM and only after reviewing a --assumeno transaction.\n'
