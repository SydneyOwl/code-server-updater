#!/bin/bash
# set -o errexit
function verge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

if [ ! -d "/app/code-server" ];then
    echo "/app/code-server not found. Check if volumes are mounted properly."
    exit 1
fi
if [[ ${RECOVER} -eq 1 ]];then
    echo "tring to recover..."
    # if ! ls ./app/backup/code-server*.bak.tar.gz &> /dev/null; then
    #     echo "File backed up is not found."
    #     exit 1
    # else
    backup_arr=(`cd /app/backup/ 2>/dev/null&& ls -t code-server*.bak.tar.gz 2>/dev/null`)
    if [ -z "$backup_arr" ]; then
        echo "No backup file found!!Abort"
        exit 1
    fi
    if [ -z ${BACKUP_FILE} ];then
        echo "Using newest backup since no recover file is specified."
        echo "Recovering backup ${backup_arr[0]}..."
        rm -rf /app/code-server
        mkdir -p /app/code-server
        tar -zxPf /app/backup/${backup_arr[0]} -C /app/code-server
        echo "Done."
    else
        if [[ "${backup_arr[@]}" =~ "$BACKUP_FILE" ]]; then
            echo "Recovering backup $BACKUP_FILE..."
            rm -rf /app/code-server
            mkdir -p /app/code-server
            tar -zxPf /app/backup/$BACKUP_FILE -C /app/code-server
            echo "Done."
        else
            echo "$BACKUP_FILE not found. Available choices: $backup_arr"
        fi
    fi
    # fi
    exit 0
fi

code_version=$(/app/code-server/bin/code-server -v | awk 'NR==2{print $1}')
update_version=$(cat /etc/update-vs-pkg/version)
if verge $code_version $update_version; then
    echo "Current Code-server version($code_version) is equal to or higher than update pkg version($update_version). Update Abort."
    exit 0
fi

if [ -f "/etc/update-vs-pkg/code-server.tar.gz" ];then
    mkdir -p /app/backup
    echo "Backuping original files..."
    cur_dateTime=$(date +%Y_%m_%d_%H_%m)
    tar -zcPf /app/backup/code-server$cur_dateTime.bak.tar.gz /app/code-server/*
    echo "Updating code-server$code_version to code-server $update_version..."
    rm -rf /app/code-server
    mkdir -p /app/code-server
    tar -zxPf /etc/update-vs-pkg/code-server.tar.gz -C /app/code-server --strip-components=1
    echo "Done. You may manually delete /app/backup/code-server$cur_dateTime.bak.tar.gz if everything is ok."
    echo "if something went wrong, run 'docker run --rm  -v code_app:/app -e RECOVER=1 -e BACKUP_FILE= `#optional` sydneymrcat/code-server-updater:latest' to undo changes."
    exit 0
else
    echo "Fatal: No update file found"
    exit 1
fi