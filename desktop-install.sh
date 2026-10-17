#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP=""
ALLOW_MIXING=0
ASSUME_NO=0
FEDORA_RELEASE="${FEDORA_RELEASE:-43}"

usage() {
    cat <<'USAGE'
Usage:
  sudo ./desktop-install.sh [--desktop NAME] --enable-fedora-mixing [--assumeno]

Options:
  --desktop NAME            kde, gnome, xfce, mate, or lxqt
  --enable-fedora-mixing    Required acknowledgement before enabling Fedora repos
  --assumeno                Ask DNF to resolve/show the transaction but not apply it
  --fedora-release NUMBER   Fedora release number (default: 43)
  -h, --help                Show this help

This is experimental. Review the proposed transaction and do not approve removals
of Azure Linux core/release packages.
USAGE
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

while (($#)); do
    case "$1" in
        --desktop)
            (($# >= 2)) || die "--desktop requires a name."
            DESKTOP="$2"; shift 2 ;;
        --enable-fedora-mixing)
            ALLOW_MIXING=1; shift ;;
        --assumeno)
            ASSUME_NO=1; shift ;;
        --fedora-release)
            (($# >= 2)) || die "--fedora-release requires a number."
            FEDORA_RELEASE="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $1 (use --help)." ;;
    esac
done

[[ $EUID -eq 0 ]] || die "Run with sudo."
[[ -r /etc/os-release ]] || die "Cannot read /etc/os-release."
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == "azurelinux" ]] || die "This installer targets Azure Linux only; detected ID=${ID:-unknown}."
[[ "$FEDORA_RELEASE" =~ ^[0-9]+$ ]] || die "FEDORA_RELEASE must be numeric."
(( ALLOW_MIXING == 1 )) || die "Refusing to mix repositories without explicit acknowledgement. Read README.md, then pass --enable-fedora-mixing."
command -v dnf5 >/dev/null 2>&1 && DNF=(dnf5) || { command -v dnf >/dev/null 2>&1 && DNF=(dnf) || die "DNF5/DNF not found."; }

if [[ -z "$DESKTOP" ]]; then
    printf 'Choose a desktop environment (experimental):\n'
    printf '  1) KDE Plasma\n  2) GNOME\n  3) XFCE\n  4) MATE\n  5) LXQt\n'
    read -r -p 'Selection [1-5]: ' choice
    case "$choice" in
        1) DESKTOP=kde ;;
        2) DESKTOP=gnome ;;
        3) DESKTOP=xfce ;;
        4) DESKTOP=mate ;;
        5) DESKTOP=lxqt ;;
        *) die "Invalid selection." ;;
    esac
fi

case "$DESKTOP" in
    kde|gnome|xfce|mate|lxqt) ;;
    *) die "Unsupported desktop '$DESKTOP'. Choose kde, gnome, xfce, mate, or lxqt." ;;
esac

[[ -f "$SCRIPT_DIR/desktop/common.sh" ]] || die "Missing desktop/common.sh."
# shellcheck source=desktop/common.sh
source "$SCRIPT_DIR/desktop/common.sh"
load_desktop_packages "$DESKTOP"

[[ ${#DESKTOP_PACKAGES[@]} -gt 0 ]] || die "No packages configured for $DESKTOP."

args=(
    install
    --enablerepo=fedora-azurelinux-experimental
    --enablerepo=updates-azurelinux-experimental
    --exclude=fedora-release\*
    --exclude=fedora-release-common\*
    --exclude=azurelinux-release\*
)
(( ASSUME_NO == 1 )) && args+=(--assumeno)

printf '\nDesktop: %s\nFedora release: %s\nPackages: %s\n' "$DESKTOP" "$FEDORA_RELEASE" "${DESKTOP_PACKAGES[*]}"
printf '\nWARNING: DNF may propose conflicting or destructive dependency changes.\n'
printf 'Do not proceed if the transaction removes Azure Linux release, boot, systemd, networking, or other core packages.\n\n'

# Repos are installed by install.sh with default Fedora release 43. If the requested
# release differs, fail closed instead of silently using a mismatched repo config.
for repo_file in /etc/yum.repos.d/azurelinux-fedora-experimental.repo /etc/yum.repos.d/azurelinux-fedora-updates-experimental.repo; do
    [[ -r "$repo_file" ]] || die "Missing $repo_file. Run ./install.sh first."
    grep -q "baseurl=.*${FEDORA_RELEASE}/" "$repo_file" || die "$repo_file does not appear configured for Fedora $FEDORA_RELEASE. Re-run install.sh with FEDORA_RELEASE=$FEDORA_RELEASE."
done

"${DNF[@]}" "${args[@]}" "${DESKTOP_PACKAGES[@]}"
