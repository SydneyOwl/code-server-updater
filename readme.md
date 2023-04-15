# README

![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/SydneyOwl/code-server-updater/ci.yml?style=for-the-badge) ![Docker Pulls](https://img.shields.io/docker/pulls/sydneymrcat/code-server-updater?style=for-the-badge) ![GitHub](https://img.shields.io/github/license/sydneyowl/code-server-updater?style=for-the-badge)

This is the Experimental updater for https://github.com/SydneyOwl/docker-code-server.
## Build

To build:
```
docker build --build-arg CODE_RELEASE= `#optional` -t sydneymrcat/code-server-updater .
```
## Update Code-Server

Before updating, you should stop container:
```
docker stop code-server
```

Run following commands to update your code app:
```
docker pull sydneymrcat/code-server-updater:latest
docker run --rm  -v code_app:/app sydneymrcat/code-server-updater:latest
```

code-server-updater always backup your original files when updating. You can manually delete them(/app/code-server*.bak.tar.gz)

**Make sure the update is successful, or don't delete them!**
## Undo changes

if there's something went wrong when updating, you could undo changes via:
```
docker run --rm  -v code_app:/app \
-e RECOVER=1 \
-e BACKUP_FILE= `#optional` \
sydneymrcat/code-server-updater:latest
```
Note: BACKUP_FILE is optional. You may specify the name of it if you have multiple backups. (e.g. BACKUP_FILE=code-server2023_04_14_13_04.bak.tar.gz)


## VersionLog

v0.1.0 Initial Release with updater of Code-server v4.11.0