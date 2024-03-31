#!/bin/bash

# libcap-2.69
printf "\033[32m[ libcap-2.69 ] installation ...\033[0m\n" || exit 1
tar -xvf libcap-2.69.tar.xz && \
cd libcap-2.69 && \
sed -i '/install -m.*STA/d' libcap/Makefile && \
make prefix=/usr lib=lib && \
make test && make prefix=/usr lib=lib install && \
cd /sources && rm -rf libcap-2.69 && \
printf "\033[32m[ libcap-2.69 ] installation successful\033[0m\n" || exit 1

# libxcrypt-4.4.36
printf "\033[32m[ libxcrypt-4.4.36 ] installation ...\033[0m\n" || exit 1
tar -xvf libxcrypt-4.4.36.tar.xz && \
cd libxcrypt-4.4.36 && \
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens && \
make && make check && make install && \
cd /sources && rm -rf libxcrypt-4.4.36 && \
printf "\033[32m[ libxcrypt-4.4.36 ] installation successful\033[0m\n" || exit 1

# shadow-4.14.5
printf "\033[32m[ shadow-4.14.5 ] installation ...\033[0m\n" || exit 1
tar -xvf shadow-4.14.5.tar.xz && \
cd shadow-4.14.5 && \
sed -i 's/groups$(EXEEXT) //' src/Makefile.in && \
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \; && \
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; && \
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \; && \
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs && \
touch /usr/bin/passwd && \
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32 && \
make && make exec_prefix=/usr install && \
make -C man install-man && \
pwconv  && grpconv && \
mkdir -p /etc/default && \
useradd -D --gid 999 || exit 1
# set password
passwd root 
cd /sources && rm -rf shadow-4.14.5 && \
printf "\033[32m[ shadow-4.14.5 ] installation successful\033[0m\n" || exit 1

# gcc-13.2.0
printf "\033[32m[ gcc-13.2.0 ] installation ...\033[0m\n" || exit 1
tar -xvf gcc-13.2.0.tar.xz && \
cd gcc-13.2.0 && \
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac && \
mkdir -v build && cd build && \
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib && \
make && ulimit -s 32768 && \
chown -R tester . && \
su tester -c "PATH=$PATH make -k check" || exit 1
../contrib/test_summary && \
make install && chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/13.2.0/include{,-fixed} && \
ln -svr /usr/bin/cpp /usr/lib && \
ln -sv gcc.1 /usr/share/man/man1/cc.1 && \
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/13.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/ && \
echo 'int main(){}' > dummy.c && \
cc dummy.c -v -Wl,--verbose &> dummy.log && \
readelf -l a.out | grep ': /lib' || exit 1
# [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log || exit 1
# should be 
# /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/Scrt1.o succeeded
# /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/crti.o succeeded
# /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/../../../../lib/crtn.o succeeded
grep -B4 '^ /usr/include' dummy.log || exit 1
# should be
#include <...> search starts here:
#  /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/include
#  /usr/local/include
#  /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.0/include-fixed
#  /usr/include
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' || exit 1
grep "/lib.*/libc.so.6 " dummy.log || exit 1
# should be 
# attempt to open /usr/lib/libc.so.6 succeeded
grep found dummy.log || exit 1 # found ld-linux-x86-64.so.2 at /usr/lib/ld-linux-x86-64.so.2
rm -v dummy.c a.out dummy.log && \
mkdir -pv /usr/share/gdb/auto-load/usr/lib && \
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib && \
cd /sources && rm -rf gcc-13.2.0 && \
printf "\033[32m[ gcc-13.2.0 ] installation successful\033[0m\n" || exit 1

# ncurses-6.4-20230520
printf "\033[32m[ ncurses-6.4-20230520 ] installation ...\033[0m\n" || exit 1
tar -xvf ncurses-6.4-20230520.tar.xz && \
cd ncurses-6.4-20230520 && \
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig && \
make && make DESTDIR=$PWD/dest install && \
install -vm755 dest/usr/lib/libncursesw.so.6.4 /usr/lib && \
rm -v  dest/usr/lib/libncursesw.so.6.4 && \
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h && \
cp -av dest/* / && \
for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done && \
ln -sfv libncursesw.so /usr/lib/libcurses.so && \
cp -v -R doc -T /usr/share/doc/ncurses-6.4-20230520 && \
cd /sources && rm -rf ncurses-6.4-20230520 && \
printf "\033[32m[ ncurses-6.4-20230520 ] installation successful\033[0m\n" || exit 1

# sed-4.9
printf "\033[32m[ sed-4.9 ] installation ...\033[0m\n" || exit 1
tar -xvf sed-4.9.tar.xz && \
cd sed-4.9 && \
./configure --prefix=/usr && \
make && make html && \
chown -R tester . && \
su tester -c "PATH=$PATH make check" && \
make install && \
install -d -m755 /usr/share/doc/sed-4.9 && \
install -m644 doc/sed.html /usr/share/doc/sed-4.9 && \
cd /sources && rm -rf sed-4.9 && \
printf "\033[32m[ sed-4.9 ] installation successful\033[0m\n" || exit 1

# psmisc-23.6
printf "\033[32m[ psmisc-23.6 ] installation ...\033[0m\n" || exit 1
tar -xvf psmisc-23.6.tar.xz && \
cd psmisc-23.6 && \
./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf psmisc-23.6 && \
printf "\033[32m[ psmisc-23.6 ] installation successful\033[0m\n" || exit 1

# gettext-0.22.4
printf "\033[32m[ gettext-0.22.4 ] installation ...\033[0m\n" || exit 1
tar -xvf gettext-0.22.4.tar.xz && \
cd gettext-0.22.4 && \
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.22.4 && \
make && make check && make install && \
chmod -v 0755 /usr/lib/preloadable_libintl.so && \
cd /sources && rm -rf gettext-0.22.4 && \
printf "\033[32m[ gettext-0.22.4 ] installation successful\033[0m\n" || exit 1

# bison-3.8.2
printf "\033[32m[ bison-3.8.2 ] installation ...\033[0m\n" || exit 1
tar -xvf bison-3.8.2.tar.xz && \
cd bison-3.8.2 && \
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2 && \
make && make check && make install && \
cd /sources && rm -rf bison-3.8.2 && \
printf "\033[32m[ bison-3.8.2 ] installation successful\033[0m\n" || exit 1

# grep-3.11
printf "\033[32m[ grep-3.11 ] installation ...\033[0m\n" || exit 1
tar -xvf grep-3.11.tar.xz && \
cd grep-3.11 && \
sed -i "s/echo/#echo/" src/egrep.sh && \
./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf grep-3.11 && \
printf "\033[32m[ grep-3.11 ] installation successful\033[0m\n" || exit 1

# bash-5.2.21
printf "\033[32m[ bash-5.2.21 ] installation ...\033[0m\n" || exit 1
tar -xvf bash-5.2.21.tar.gz && \
cd bash-5.2.21 && \
patch -Np1 -i ../bash-5.2.21-upstream_fixes-1.patch && \
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.21 && \
make && chown -R tester . && \
su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF || exit 1
make install && exec /usr/bin/bash --login && \
cd /sources && rm -rf bash-5.2.21 && \
printf "\033[32m[ bash-5.2.21 ] installation successful\033[0m\n" || exit 1

# libtool-2.4.7
printf "\033[32m[ libtool-2.4.7 ] installation ...\033[0m\n" || exit 1
tar -xvf libtool-2.4.7.tar.xz && \
cd libtool-2.4.7 && \
./configure --prefix=/usr && \
make && make -k check &&  make install && \
rm -fv /usr/lib/libltdl.a && \
cd /sources && rm -rf libtool-2.4.7 && \
printf "\033[32m[ libtool-2.4.7 ] installation successful\033[0m\n" || exit 1

# gdbm-1.23
printf "\033[32m[ gdbm-1.23 ] installation ...\033[0m\n" || exit 1
tar -xvf gdbm-1.23.tar.gz && \
cd gdbm-1.23 && \
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat && \
make && make check && make install && \
cd /sources && rm -rf gdbm-1.23 && \
printf "\033[32m[ gdbm-1.23 ] installation successful\033[0m\n" || exit 1

# gperf-3.1
printf "\033[32m[ gperf-3.1 ] installation ...\033[0m\n" || exit 1
tar -xvf gperf-3.1.tar.gz && \
cd gperf-3.1 && \
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1 && \
make && make -j1 check && make install && \
cd /sources && rm -rf gperf-3.1 && \
printf "\033[32m[ gperf-3.1 ] installation successful\033[0m\n" || exit 1

# expat-2.6.2
printf "\033[32m[ expat-2.6.2 ] installation ...\033[0m\n" || exit 1
tar -xvf expat-2.6.2.tar.xz && \
cd expat-2.6.2 && \
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.0 && \
make && make check && make install && \
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.0 && \
cd /sources && rm -rf expat-2.6.2 && \
printf "\033[32m[ expat-2.6.2 ] installation successful\033[0m\n" || exit 1

# inetutils-2.5
printf "\033[32m[ inetutils-2.5 ] installation ...\033[0m\n" || exit 1
tar -xvf inetutils-2.5.tar.xz && \
cd inetutils-2.5 && \
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers && \
make && make check && make install && \
mv -v /usr/{,s}bin/ifconfig && \
cd /sources && rm -rf inetutils-2.5 && \
printf "\033[32m[ inetutils-2.5 ] installation successful\033[0m\n" || exit 1

# less-643
printf "\033[32m[ less-643 ] installation ...\033[0m\n" || exit 1
tar -xvf less-643.tar.gz && \
cd less-643 && \
./configure --prefix=/usr --sysconfdir=/etc && \
make && make check && make install && \
cd /sources && rm -rf less-643 && \
printf "\033[32m[ less-643 ] installation successful\033[0m\n" || exit 1

# perl-5.38.2
printf "\033[32m[ perl-5.38.2 ] installation ...\033[0m\n" || exit 1
tar -xvf perl-5.38.2.tar.xz && \
cd perl-5.38.2 && \
export BUILD_ZLIB=False && \
export BUILD_BZIP2=0 && \
sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl      \
             -Darchlib=/usr/lib/perl5/5.38/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads && \

make && TEST_JOBS=$(nproc) make test_harness && \
make install && unset BUILD_ZLIB BUILD_BZIP2 && \
cd /sources && rm -rf perl-5.38.2 && \
printf "\033[32m[ perl-5.38.2 ] installation successful\033[0m\n" || exit 1

# XML-Parser-2.47
printf "\033[32m[ XML-Parser-2.47 ] installation ...\033[0m\n" || exit 1
tar -xvf XML-Parser-2.47.tar.gz && \
cd XML-Parser-2.47 && \
perl Makefile.PL && \
make && make test && \
make install && \
cd /sources && rm -rf XML-Parser-2.47 && \
printf "\033[32m[ XML-Parser-2.47 ] installation successful\033[0m\n" || exit 1

# intltool-0.51.0
printf "\033[32m[ intltool-0.51.0 ] installation ...\033[0m\n" || exit 1
tar -xvf intltool-0.51.0.tar.gz && \
cd intltool-0.51.0 && \
sed -i 's:\\\${:\\\$\\{:' intltool-update.in && \
./configure --prefix=/usr && \
make && make check && \
make install && \
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO && \
cd /sources && rm -rf intltool-0.51.0 && \
printf "\033[32m[ intltool-0.51.0 ] installation successful\033[0m\n" || exit 1