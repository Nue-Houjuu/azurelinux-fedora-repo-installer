#Azure Linux Fedora Repo Installer

Adds the official Fedora repositories to Microsoft Azure Linux, allowing installation of Fedora packages and optional desktop environments.

⚠️ Warning
This project is intended for testing and experimentation only. It is NOT affiliated with, endorsed by, or supported by Microsoft or the Fedora Project. Mixing Fedora repositories with Azure Linux may cause package conflicts or produce an unsupported system. I did this more for me while I was testing Azure Linux.

#How it works

This project bridges the gap between the minimal, cloud-native Azure Linux environment and the extensive software ecosystem of Fedora. The process is divided into two logical stages to ensure system integrity:

    Base Configuration (install.sh): This script acts as the foundation by enabling the official Fedora repositories within Azure Linux. This allows the system to resolve and pull missing dependencies that are absent in the default Azure Linux image.

    Desktop Deployment (desktop-install.sh): This stage deploys the graphical environment for example (Xfce/KDE)
