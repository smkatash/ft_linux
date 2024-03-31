#!/bin/bash 
printf "\033[[ CLEAN-UP ] ...\033[0m\n" || exit 1
rm -rf /tmp/* && \
find /usr/lib /usr/libexec -name \*.la -delete && \ 
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf && \
userdel -r tester && \
printf "\033[[ CLEAN-UP ] successful\033[0m\n" || exit 1
