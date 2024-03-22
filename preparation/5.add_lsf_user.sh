#!/bin/bash

groupadd lfs || exit 1
useradd -s /bin/bash -g lfs -m -k /dev/null lfs || exit 1

# set password in the prompt
passwd lfs  


# grant lfs full access to all the directories under $LFS by making lfs the owner
chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac || exit 1

# switch to lsf user!
su - lfs

printf "\033[36[m[ SUCCESS ] lfs user created\033[0m\n"