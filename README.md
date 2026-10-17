# Azure Linux + Fedora Repository Installer

Experimental helper scripts for evaluating Fedora desktop packages on **Azure Linux 4.0**.

> **Warning:** This project is experimental and unsupported. Azure Linux is not a Fedora respin. Mixing Fedora RPMs with Azure Linux can create dependency conflicts, replace core components, or make the system unbootable. Azure Linux 4.0 is a preview release. Test in a disposable VM or snapshot first.

## Safety defaults

- Fedora repositories are installed **disabled** (`enabled=0`).
- RPM signature checking is enabled (`gpgcheck=1`).
- The scripts never run `distro-sync`, never remove packages intentionally, and exclude Azure Linux/Fedora release packages from the desktop install transaction.
- Installing a desktop requires an explicit `--enable-fedora-mixing` acknowledgement.
- `--assumeno` is supported for reviewing the proposed transaction without applying it, provided the selected package manager supports that option.
- Fedora repository release is configurable; default is Fedora 43. Only use a Fedora release compatible with the target package set.

These safeguards reduce risk; they do not make cross-distribution package mixing safe.

## Contents

```text
.
├── install.sh
├── desktop-install.sh
├── README.md
├── LICENSE
├── .gitignore
├── repos/
│   ├── fedora.repo
│   ├── fedora-updates.repo
│   └── repos.txt
└── desktop/
    ├── common.sh
    ├── gnome.sh
    ├── kde.sh
    ├── lxqt.sh
    ├── mate.sh
    └── xfce.sh
```

## Requirements

- Azure Linux 4.0 x86_64, for the intended target.
- Bash and one supported package-manager command: `tdnf`, `dnf5`, or `dnf`.
- Root privileges for repository installation and package installation.
- Network access to official Fedora mirrors.

The scripts intentionally refuse to modify an ordinary Fedora host or an unrelated distribution by default. Package-manager options can differ by version; review the proposed transaction before confirming it.

## Install repository definitions

Clone the project, inspect it, then run:

```bash
git clone https://github.com/Nue-Houjuu/azurelinux-fedora-repo-installer.git
cd azurelinux-fedora-repo-installer
less install.sh
sudo ./install.sh
```

The repository files are copied to `/etc/yum.repos.d/` with Fedora repositories disabled. Unique filenames are used so the installer does not overwrite the standard `fedora.repo` files. The installer backs up any existing files with the same names before replacing them.

Check the result using the package manager available on your system:

```bash
tdnf repolist --all
# Or, if installed:
dnf5 repolist --all
# Or:
dnf repolist --all
```

The repo IDs are `fedora-azurelinux-experimental` and `updates-azurelinux-experimental`.

## Preview a desktop transaction

Always review the package transaction before applying it. For example:

```bash
sudo ./desktop-install.sh --desktop kde --enable-fedora-mixing --assumeno
```

To actually proceed, remove `--assumeno`:

```bash
sudo ./desktop-install.sh --desktop kde --enable-fedora-mixing
```

You must explicitly acknowledge Fedora/Azure Linux package mixing. The package names are best-effort and have not been validated on every Azure Linux 4.0 image. The package manager may report missing packages, unsupported options, or dependency conflicts. Do not force a transaction that proposes removing core Azure Linux packages.

Available desktop selections: `kde`, `gnome`, `xfce`, `mate`, `lxqt`.

Interactive selector:

```bash
sudo ./desktop-install.sh --enable-fedora-mixing --assumeno
```

## Repository release

Default is Fedora 43. To select another release, set `FEDORA_RELEASE` when installing repo files, and use the same value for desktop package installation:

```bash
sudo FEDORA_RELEASE=43 ./install.sh
sudo FEDORA_RELEASE=43 ./desktop-install.sh --desktop xfce --enable-fedora-mixing --assumeno
```

Do not assume a Fedora release is compatible simply because its repository exists. Review the Fedora lifecycle and package compatibility before changing it.

## Rollback repository definitions

The installer prints the backup path when it replaces a same-named repo file. Restore those files manually if needed. To disable the experimental repos, edit these files:

- `/etc/yum.repos.d/azurelinux-fedora-experimental.repo`
- `/etc/yum.repos.d/azurelinux-fedora-updates-experimental.repo`

Set `enabled=0` in each repository section. This manual method works without relying on a package-manager-specific `config-manager` command. If your package manager provides a supported repository configuration command, you may use it instead.

This only disables the repositories; it does **not** remove packages already installed from Fedora.

## Security notes

- `gpgcheck=1` is enabled. Fedora signing keys must be available on the target system for RPM signature verification. If the package manager reports a missing key, stop and install/verify the official Fedora signing key using Fedora's documented process. Do not work around the error by setting `gpgcheck=0`.
- Repository metadata signing (`repo_gpgcheck`) is not forced on because repository metadata-signing support/configuration can vary; RPM package signature checking remains enabled.
- Never run an installer from the Internet with `curl | sudo bash`.
- Inspect changes and test in a disposable VM snapshot before using them on a system you care about.

## Current status

This is an experimental project scaffold, not a supported system migration tool. Shell syntax checks do not validate package availability, dependency resolution, package-manager option compatibility, or the resulting desktop session. A successful package transaction does not prove that the desktop, graphics stack, audio, networking, boot, or future updates will work.
