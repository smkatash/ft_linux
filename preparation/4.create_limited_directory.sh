#!/bin/bash
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin} || exit 1

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done || exit 1

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac || exit 1

mkdir -pv $LFS/tools || exit 1

printf "\033[36[m[ SUCCESS ] Limited directory created\033[0m\n"