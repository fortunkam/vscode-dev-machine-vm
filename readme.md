Current issues with Dev Machine build

- code extensions not installed, new PS session required to pick up new Path variable changes (Can be fixed by running part of the script that does the extensions)
- local user needs adding to the docker-users local group (can be fixed by running `Add-LocalGroupMember -Group "docker-users" -Member "<machine_name>\<user_name>"` and then rebooting/log out)
- Windows terminal isn't installed
- Docker desktop requires an additional WSL2 install (find install here then restart docker desktop, https://docs.microsoft.com/en-us/windows/wsl/install-win10#step-4---download-the-linux-kernel-update-package)
