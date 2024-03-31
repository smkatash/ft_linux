#!/bin/bash

# Man-pages-6.06
printf "\033[32m[ man-pages-6.06 ] installation ...\033[0m\n" || exit 1
tar -xvf man-pages-6.06.tar.xz && \
cd man-pages-6.06 && \
rm -v man3/crypt* && make prefix=/usr install && \
cd /sources && rm -rf man-pages-6.06 && \
printf "\033[32m[ man-pages-6.06 ] installation successful\033[0m\n" || exit 1

# iana-etc-20240125
printf "\033[32m[ iana-etc-20240125 ] installation ...\033[0m\n" || exit 1
tar -xvf iana-etc-20240125.tar.gz && \
cd iana-etc-20240125 && \
cp services protocols /etc && \
cd /sources && rm -rf iana-etc-20240125 && \
printf "\033[32m[ iana-etc-20240125 ] installation successful\033[0m\n" || exit 1

# glibc-2.39
printf "\033[32m[ glibc-2.39 ] installation ...\033[0m\n" || exit 1
tar -xvf glibc-2.39.tar.xz && \
cd glibc-2.39 && \
patch -Np1 -i ../glibc-2.39-fhs-1.patch && \
mkdir -v build && cd build && \
echo "rootsbindir=/usr/sbin" > configparms && \
../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=4.19                     \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib && \
make && \
# make check && \
touch /etc/ld.so.conf && \
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile && \
make install && sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd || exit 1

mkdir -pv /usr/lib/locale && \
localedef -i C -f UTF-8 C.UTF-8 && \
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8 && \
localedef -i de_DE -f ISO-8859-1 de_DE && \
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro && \
localedef -i de_DE -f UTF-8 de_DE.UTF-8 && \
localedef -i el_GR -f ISO-8859-7 el_GR && \
localedef -i en_GB -f ISO-8859-1 en_GB && \
localedef -i en_GB -f UTF-8 en_GB.UTF-8 && \
localedef -i en_HK -f ISO-8859-1 en_HK && \
localedef -i en_PH -f ISO-8859-1 en_PH && \
localedef -i en_US -f ISO-8859-1 en_US && \
localedef -i en_US -f UTF-8 en_US.UTF-8 && \
localedef -i es_ES -f ISO-8859-15 es_ES@euro && \
localedef -i es_MX -f ISO-8859-1 es_MX && \
localedef -i fa_IR -f UTF-8 fa_IR && \
localedef -i fr_FR -f ISO-8859-1 fr_FR && \
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro && \
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8 && \
localedef -i is_IS -f ISO-8859-1 is_IS && \
localedef -i is_IS -f UTF-8 is_IS.UTF-8 && \
localedef -i it_IT -f ISO-8859-1 it_IT && \
localedef -i it_IT -f ISO-8859-15 it_IT@euro && \
localedef -i it_IT -f UTF-8 it_IT.UTF-8 && \
localedef -i ja_JP -f EUC-JP ja_JP && \
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true && \
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 && \
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro && \
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R && \
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8 && \
localedef -i se_NO -f UTF-8 se_NO.UTF-8 && \
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8 && \
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8 && \
localedef -i zh_CN -f GB18030 zh_CN.GB18030 && \
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS && \
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8 || exit 1
cd /sources && rm -rf glibc-2.39 && \
printf "\033[32m[ glibc-2.39 ] installation successful\033[0m\n" || exit 1

# zlib-1.3.1
printf "\033[32m[ zlib-1.3.1 ] installation ...\033[0m\n" || exit 1
tar -xvf zlib-1.3.1.tar.gz && \
cd zlib-1.3.1 && \
./configure --prefix=/usr && \
make && make check && \
make install && rm -fv /usr/lib/libz.a && \
cd /sources && rm -rf zlib-1.3.1 && \
printf "\033[32m[ zlib-1.3.1 ] installation successful\033[0m\n" || exit 1

# bzip2-1.0.8
printf "\033[32m[ bzip2-1.0.8 ] installation ...\033[0m\n" || exit 1
tar -xvf bzip2-1.0.8.tar.gz && \
cd bzip2-1.0.8 && \
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch && \
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile && \
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile && \
make -f Makefile-libbz2_so && make clean && \
make && make PREFIX=/usr install && \
cp -av libbz2.so.* /usr/lib && ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so && \
cp -v bzip2-shared /usr/bin/bzip2 && \
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done || exit 1
rm -fv /usr/lib/libbz2.a && \
cd /sources && rm -rf bzip2-1.0.8 && \
printf "\033[32m[ bzip2-1.0.8 ] installation successful\033[0m\n" || exit 1

# xz-5.4.6
printf "\033[32m[ xz-5.4.6 ] installation ...\033[0m\n" || exit 1
tar -xvf xz-5.4.6.tar.xz && \
cd xz-5.4.6 && \
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.4.6 && \
make && make check && \
make install && \
cd /sources && rm -rf xz-5.4.6 && \
printf "\033[32m[ xz-5.4.6 ] installation successful\033[0m\n" || exit 1

# zstd-1.5.5
printf "\033[32m[ zstd-1.5.5 ] installation ...\033[0m\n" || exit 1
tar -xvf zstd-1.5.5.tar.gz && \
cd zstd-1.5.5 && \
make prefix=/usr && \
make check && make prefix=/usr install && \
rm -v /usr/lib/libzstd.a && \
cd /sources && rm -rf zstd-1.5.5 && \
printf "\033[32m[ zstd-1.5.5 ] installation successful\033[0m\n" || exit 1

# file-5.45
printf "\033[32m[ file-5.45 ] installation ...\033[0m\n" || exit 1
tar -xvf file-5.45.tar.gz && \
cd file-5.45 && \
./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf file-5.45 && \
printf "\033[32m[ file-5.45 ] installation successful\033[0m\n" || exit 1

# readline-8.2
printf "\033[32m[ readline-8.2 ] installation ...\033[0m\n" || exit 1
tar -xvf readline-8.2.tar.gz && \
cd readline-8.2 && \
sed -i '/MV.*old/d' Makefile.in && \
sed -i '/{OLDSUFF}/c:' support/shlib-install && \
patch -Np1 -i ../readline-8.2-upstream_fixes-3.patch && \
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2 && \
make SHLIB_LIBS="-lncursesw" && \
make SHLIB_LIBS="-lncursesw" install && \
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2 && \
cd /sources && rm -rf readline-8.2 && \
printf "\033[32m[ readline-8.2 ] installation successful\033[0m\n" || exit 1

# m4-1.4.19
printf "\033[32m[ m4-1.4.19 ] installation ...\033[0m\n" || exit 1
tar -xvf m4-1.4.19.tar.xz && \
cd m4-1.4.19 && \
./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf m4-1.4.19 && \
printf "\033[32m[ m4-1.4.19 ] installation successful\033[0m\n" || exit 1

# bc-6.7.5
printf "\033[32m[ bc-6.7.5 ] installation ...\033[0m\n" || exit 1
tar -xvf bc-6.7.5.tar.xz && \
cd bc-6.7.5 && \
CC=gcc ./configure --prefix=/usr -G -O3 -r && \
make && make test && make install && \
cd /sources && rm -rf bc-6.7.5 && \
printf "\033[32m[ bc-6.7.5 ] installation successful\033[0m\n" || exit 1

# flex-2.6.4
printf "\033[32m[ flex-2.6.4 ] installation ...\033[0m\n" || exit 1
tar -xvf flex-2.6.4.tar.gz && \
cd flex-2.6.4 && \
./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static && \
make && make check && make install && \
ln -sv flex /usr/bin/lex && \
ln -sv flex.1 /usr/share/man/man1/lex.1 && \
cd /sources && rm -rf flex-2.6.4 && \
printf "\033[32m[ flex-2.6.4 ] installation successful\033[0m\n" || exit 1

# tcl8.6.13-src
printf "\033[32m[ tcl8.6.13-src ] installation ...\033[0m\n" || exit 1
tar -xvf tcl8.6.13-src.tar.gz && \
cd tcl8.6.13-src && \
SRCDIR=$(pwd) && cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man && \
make && \
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh && \
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.5|/usr/lib/tdbc1.1.5|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5|/usr/include|"            \
    -i pkgs/tdbc1.1.5/tdbcConfig.sh && \
sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.3|/usr/lib/itcl4.2.3|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.3/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.3|/usr/include|"            \
    -i pkgs/itcl4.2.3/itclConfig.sh && \
unset SRCDIR && make test && make install && \
chmod -v u+w /usr/lib/libtcl8.6.so && \
make install-private-headers && \
ln -sfv tclsh8.6 /usr/bin/tclsh && \
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3 && \
cd /sources && rm -rf tcl8.6.13-src && \
printf "\033[32m[ tcl8.6.13-src ] installation successful\033[0m\n" || exit 1


# expect5.45.4
printf "\033[32m[ expect5.45.4 ] installation ...\033[0m\n" || exit 1
tar -xvf expect5.45.4.tar.gz && \
cd expect5.45.4 && \
python3 -c 'from pty import spawn; spawn(["echo", "ok"])' | grep -q "ok" && \
echo "Command returned 'ok'." || exit 1
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include && \
make && make test && \
make install && \
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib && \
cd /sources && rm -rf expect5.45.4 && \
printf "\033[32m[ expect5.45.4 ] installation successful\033[0m\n" || exit 1

# dejagnu-1.6.3
printf "\033[32m[ dejagnu-1.6.3 ] installation ...\033[0m\n" || exit 1
tar -xvf dejagnu-1.6.3.tar.gz && \
cd dejagnu-1.6.3 && \
mkdir -v build && cd build && \
../configure --prefix=/usr && \
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi && \
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi && \
make check && \
make install && \
install -v -dm755  /usr/share/doc/dejagnu-1.6.3 && \
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3 && \
cd /sources && rm -rf dejagnu-1.6.3 && \
printf "\033[32m[ dejagnu-1.6.3 ] installation successful\033[0m\n" || exit 1

# pkgconf-2.1.1
printf "\033[32m[ pkgconf-2.1.1 ] installation ...\033[0m\n" || exit 1
tar -xvf pkgconf-2.1.1.tar.xz && \
cd pkgconf-2.1.1 && \
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.1.1 && \
make && make install && \
ln -sv pkgconf   /usr/bin/pkg-config && \
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1 && \
cd /sources && rm -rf pkgconf-2.1.1 && \
printf "\033[32m[ pkgconf-2.1.1 ] installation successful\033[0m\n" || exit 1

# binutils-2.42
printf "\033[32m[ binutils-2.42 ] installation ...\033[0m\n" || exit 1
tar -xvf binutils-2.42.tar.xz && \
cd binutils-2.42 && \
mkdir -v build && cd build && \
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib  \
             --enable-default-hash-style=gnu && \
make tooldir=/usr && \
make -k check && \
grep '^FAIL:' $(find -name '*.log') && \
make tooldir=/usr install && \
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a && \
cd /sources && rm -rf binutils-2.42 && \
printf "\033[32m[ binutils-2.42 ] installation successful\033[0m\n" || exit 1

# gmp-6.3.0
printf "\033[32m[ gmp-6.3.0 ] installation ...\033[0m\n" || exit 1
tar -xvf gmp-6.3.0.tar.xz && \
cd gmp-6.3.0 && \
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/gmp-6.3.0 && \
make && make html && \
make check 2>&1 | tee gmp-check-log && \
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log && \
make install && make install-html && \
cd /sources && rm -rf gmp-6.3.0 && \
printf "\033[32m[ gmp-6.3.0 ] installation successful\033[0m\n" || exit 1

# mpfr-4.2.1
printf "\033[32m[ mpfr-4.2.1 ] installation ...\033[0m\n" || exit 1
tar -xvf mpfr-4.2.1.tar.xz && \
cd mpfr-4.2.1 && \
make check && \
make install && make install-html && \
cd /sources && rm -rf mpfr-4.2.1 && \
printf "\033[32m[ mpfr-4.2.1 ] installation successful\033[0m\n" || exit 1

# mpc-1.3.1
printf "\033[32m[ mpc-1.3.1 ] installation ...\033[0m\n" || exit 1
tar -xvf mpc-1.3.1.tar.gz && \
cd mpc-1.3.1 && \
make check && \
make install && make install-html && \
cd /sources && rm -rf mpc-1.3.1 && \
printf "\033[32m[ mpc-1.3.1 ] installation successful\033[0m\n" || exit 1


# attr-2.5.2
printf "\033[32m[ attr-2.5.2 ] installation ...\033[0m\n" || exit 1
tar -xvf attr-2.5.2.tar.gz && \
cd attr-2.5.2 && \
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2 && \
make && make check && make install && \
cd /sources && rm -rf attr-2.5.2 && \
printf "\033[32m[ attr-2.5.2 ] installation successful\033[0m\n" || exit 1

# acl-2.3.2
printf "\033[32m[ acl-2.3.2 ] installation ...\033[0m\n" || exit 1
tar -xvf acl-2.3.2.tar.xz && \
cd acl-2.3.2 && \
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2 && \
make && make install && \
cd /sources && rm -rf acl-2.3.2 && \
printf "\033[32m[ acl-2.3.2 ] installation successful\033[0m\n" || exit 1