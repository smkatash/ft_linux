#!/bin/bash

sudo su -
if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ ERROR ] LFS variable not set in root. Exiting...\033[0m\n"
	exit 1
else
	printf "\033[32m[ SUCCESS ] LFS variable was set in root successfully\033[0m\n"
fi 

chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools} && \
case $(uname -m) in
  x86_64) chown -R root:root $LFS/lib64 ;;
esac || exit 1

mkdir -pv $LFS/{dev,proc,sys,run} && \
mount -v --bind /dev $LFS/dev && \
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts && \
mount -vt proc proc $LFS/proc && \
mount -vt sysfs sysfs $LFS/sys && \
mount -vt tmpfs tmpfs $LFS/run || exit 1

if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi || exit 1

# enter chroot
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login || exit 1

# create directories
mkdir -pv /{boot,home,mnt,opt,srv} && \
mkdir -pv /etc/{opt,sysconfig} && \
mkdir -pv /lib/firmware && \
mkdir -pv /media/{floppy,cdrom} && \
mkdir -pv /usr/{,local/}{include,src} && \
mkdir -pv /usr/local/{bin,lib,sbin} && \
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man} && \
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo} && \
mkdir -pv /usr/{,local/}share/man/man{1..8} && \
mkdir -pv /var/{cache,local,log,mail,opt,spool} && \
mkdir -pv /var/lib/{color,misc,locate} || exit 1

ln -sfv /run /var/run && \
ln -sfv /run/lock /var/lock || exit 1

install -dv -m 0750 /root && \ 
install -dv -m 1777 /tmp /var/tmp || exit 1

# create essential symlinks
ln -sv /proc/self/mounts /etc/mtab || exit 1

cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF 

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd && \
echo "tester:x:101:" >> /etc/group && \
install -o tester -d /home/tester || exit 1

exec /usr/bin/bash --login && \
touch /var/log/{btmp,lastlog,faillog,wtmp} && \
chgrp -v utmp /var/log/lastlog && \
chmod -v 664  /var/log/lastlog && \
chmod -v 600  /var/log/btmp || exit 1

printf "\033[36[m[ SUCCESS ] Entered chroot\033[0m\n"