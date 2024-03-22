#!/bin/bash

# Define the contents of the .bash_profile
BASH_PROFILE_CONTENT=$(cat <<EOF
exec env -i HOME=\$HOME TERM=\$TERM PS1='\u:\w\$ ' /bin/bash
EOF
)

echo "$BASH_PROFILE_CONTENT" > ~/.bash_profile

if [ $? -eq 0 ]; then
    printf "\033[36m[ SUCCESS ] ~/.bash_profile created\033[0m\n"
else
    printf "\033[31m[ ERROR ] ~/.bash_profile not set. Exiting...\033[0m\n" 
    exit 1
fi

# Define the contents of the .bashrc
BASHRC_CONTENT=$(cat <<EOF
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=\$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:\$PATH; fi
PATH=\$LFS/tools/bin:\$PATH
CONFIG_SITE=\$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j\$(nproc)
EOF
)

echo "$BASHRC_CONTENT" > ~/.bashrc

if [ $? -eq 0 ]; then
    printf "\033[36m[ SUCCESS ] ~/.bashrc created\033[0m\n"
else
    printf "\033[31m[ ERROR ] ~/.bashrc not set. Exiting...\033[0m\n" 
    exit 1
fi

source ~/.bash_profile

printf "\033[36[m[ SUCCESS ] Environment is set-up\033[0m\n"
