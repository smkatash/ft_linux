#!/bin/bash
if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ ERROR ] LFS variable not set. Exiting...\033[0m\n"
	exit 1
fi 

mkdir -pv $LFS/sources		|| exit 1
chmod -v a+wt $LFS/sources	|| exit 1
wget -q --show-progress	--input-file=resources/wget-list-sysv --continue --directory-prefix=$LFS/sources 
cp -v resources/md5sums $LFS/sources && pushd $LFS/sources && md5sum -c md5sums && popd 

chown root:root $LFS/sources/*

printf "\033[36[m[ SUCCESS ] Packages and patches are installed\033[0m\n"