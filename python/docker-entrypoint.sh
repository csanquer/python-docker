#!/bin/bash
set -e

USER_ID=${USER_ID:-1000}
USERNAME=${USERNAME:-'dev'}
GROUP_ID=${GROUP_ID:-1000}
GROUPNAME=${GROUPNAME:-'dev'}
HOMEDIR=${HOMEDIR:-"/home/$USERNAME"}

groupadd -f -g $GROUP_ID  $GROUPNAME
useradd -u $USER_ID -g $GROUP_ID -d $HOMEDIR $USERNAME
usermod -a -G admin $USERNAME

mkdir -p $HOMEDIR/.ssh
cp -n /ssh_config $HOMEDIR/.ssh/config

if [ -n "$SSH_PRIVATE_KEY" ]; then
    echo "$SSH_PRIVATE_KEY" > $HOMEDIR/.ssh/id_rsa
    chmod 0600 $HOMEDIR/.ssh/id_rsa

    if [ -n "$SSH_PUBLIC_KEY" ]; then
        echo "$SSH_PUBLIC_KEY" > $HOMEDIR/.ssh/id_rsa.pub
        chmod 0640 $HOMEDIR/.ssh/id_rsa.pub
    fi
fi

chown -R $USERNAME:$GROUPNAME $HOMEDIR
if [ -n "$GIT_USER_NAME" ]; then
    gosu $USERNAME git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    gosu $USERNAME /usr/bin/git config --global user.email "$GIT_USER_EMAIL"
fi

chown -R $USERNAME:$GROUPNAME /srv/apps

gosu $USERNAME "$@"
