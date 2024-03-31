#!/bin/bash

# systemd-255
printf "\033[32m[ systemd-255 ] installation ...\033[0m\n" || exit 1
tar -xvf systemd-255.tar.gz && \
cd systemd-255 && \
sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in && \
sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in && \
sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h && \
mkdir -p build && cd build && \
meson setup \
      --prefix=/usr                 \
      --buildtype=release           \
      -Dmode=release                \
      -Ddev-kvm-mode=0660           \
      -Dlink-udev-shared=false      \
      -Dlogind=false                \
      -Dvconsole=false              \
      .. && \
export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | \
                      awk '{print $3}' | tr -d ",'" | grep -v 'udevadm') && \
ninja udevadm systemd-hwdb                                           \
      $(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
      $(realpath libudev.so --relative-to .)                         \
      $udev_helpers || exit 1

install -vm755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network} && \
install -vm755 -d /usr/{lib,share}/pkgconfig && \
install -vm755 udevadm                             /usr/bin/ && \
install -vm755 systemd-hwdb                        /usr/bin/udev-hwdb && \
ln      -svfn  ../bin/udevadm                      /usr/sbin/udevd && \
cp      -av    libudev.so{,*[0-9]}                 /usr/lib/ && \
install -vm644 ../src/libudev/libudev.h            /usr/include/ && \
install -vm644 src/libudev/*.pc                    /usr/lib/pkgconfig/ && \
install -vm644 src/udev/*.pc                       /usr/share/pkgconfig/ && \
install -vm644 ../src/udev/udev.conf               /etc/udev/ && \
install -vm644 rules.d/* ../rules.d/README         /usr/lib/udev/rules.d/ && \
install -vm644 $(find ../rules.d/*.rules 
                      -not -name '*power-switch*') /usr/lib/udev/rules.d/ && \
install -vm644 hwdb.d/*  ../hwdb.d/{*.hwdb,README} /usr/lib/udev/hwdb.d/ && \
install -vm755 $udev_helpers                       /usr/lib/udev && \
install -vm644 ../network/99-default.link          /usr/lib/udev/network || exit 1 

tar -xvf ../../udev-lfs-20230818.tar.xz && \
make -f udev-lfs-20230818/Makefile.lfs install || exit 1

tar -xf ../../systemd-man-pages-255.tar.xz                            \
    --no-same-owner --strip-components=1                              \
    -C /usr/share/man --wildcards '*/udev*' '*/libudev*'              \
                                  '*/systemd.link.5'                  \
                                  '*/systemd-'{hwdb,udevd.service}.8 && \

sed 's|systemd/network|udev/network|'                                 \
    /usr/share/man/man5/systemd.link.5                                \
  > /usr/share/man/man5/udev.link.5 && \
sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8   \
                               > /usr/share/man/man8/udev-hwdb.8 && \
sed 's|lib.*udevd|sbin/udevd|'                                        \
    /usr/share/man/man8/systemd-udevd.service.8                       \
  > /usr/share/man/man8/udevd.8 && \
rm /usr/share/man/man*/systemd* && \
unset udev_helpers && \
udev-hwdb update && \
cd /sources && rm -rf systemd-255 && \
printf "\033[32m[ systemd-255 ] installation successful\033[0m\n" || exit 1

# man-db-2.12.0
printf "\033[32m[ man-db-2.12.0 ] installation ...\033[0m\n" || exit 1
tar -xvf man-db-2.12.0.tar.xz && \
cd man-db-2.12.0 && \
./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.12.0 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir= && \
make && make check && make install && \
cd /sources && rm -rf man-db-2.12.0 && \
printf "\033[32m[ man-db-2.12.0 ] installation successful\033[0m\n" || exit 1

# procps-ng-4.0.4
printf "\033[32m[ procps-ng-4.0.4 ] installation ...\033[0m\n" || exit 1
tar -xvf procps-ng-4.0.4.tar.xz && \
cd procps-ng-4.0.4 && \
make && make -k check && make install && \
cd /sources && rm -rf procps-ng-4.0.4 && \
printf "\033[32m[ procps-ng-4.0.4 ] installation successful\033[0m\n" || exit 1

# util-linux-2.39.3
printf "\033[32m[ util-linux-2.39.3 ] installation ...\033[0m\n" || exit 1
tar -xvf util-linux-2.39.3.tar.xz && \
cd util-linux-2.39.3 && \
sed -i '/test_mkfds/s/^/#/' tests/helpers/Makemodule.am && \
./configure --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --runstatedir=/run   \
            --sbindir=/usr/sbin  \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.39.3 && \
make && chown -R tester . && \
su tester -c "make -k check" && \
make install && \
cd /sources && rm -rf util-linux-2.39.3 && \
printf "\033[32m[ util-linux-2.39.3 ] installation successful\033[0m\n" || exit 1

# e2fsprogs-1.47.0
printf "\033[32m[ e2fsprogs-1.47.0 ] installation ...\033[0m\n" || exit 1
tar -xvf e2fsprogs-1.47.0.tar.gz && \
cd e2fsprogs-1.47.0 && \
mkdir -v build && cd build && \
../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck && \
make && make check && make install && \
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a && \
gunzip -v /usr/share/info/libext2fs.info.gz && \
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info && \
sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf && \
cd /sources && rm -rf e2fsprogs-1.47.0 && \
printf "\033[32m[ e2fsprogs-1.47.0 ] installation successful\033[0m\n" || exit 1

# sysklogd-1.5.1
printf "\033[32m[ sysklogd-1.5.1 ] installation ...\033[0m\n" || exit 1
tar -xvf sysklogd-1.5.1.tar.gz && \
cd sysklogd-1.5.1 && \
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c && \
sed -i 's/union wait/int/' syslogd.c && \
make && make BINDIR=/sbin install || exit 1
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF
cd /sources && rm -rf sysklogd-1.5.1 && \
printf "\033[32m[ sysklogd-1.5.1 ] installation successful\033[0m\n" || exit 1

# sysvinit-3.08
printf "\033[32m[ sysvinit-3.08 ] installation ...\033[0m\n" || exit 1
tar -xvf sysvinit-3.08.tar.xz && \
cd sysvinit-3.08 && \
patch -Np1 -i ../sysvinit-3.08-consolidated-1.patch && \
make && make install && \
cd /sources && rm -rf sysvinit-3.08 && \
printf "\033[32m[ sysvinit-3.08 ] installation successful\033[0m\n" || exit 1