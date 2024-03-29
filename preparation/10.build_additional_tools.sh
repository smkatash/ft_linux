#!/bin/bash

# Install gettext-0.22.4
install_gettext() {
    printf "\033[32m[ gettext-0.22.4 ] installation ...\033[0m\n" || exit 1
    tar -xvf gettext-0.22.4.tar.xz && \
    cd gettext-0.22.4 && \
    ./configure --disable-shared && \
    make && cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin && \
    cd $LFS/sources && rm -rf gettext-0.22.4 && \
    printf "\033[32m[ gettext-0.22.4 ] installation successful\033[0m\n" || exit 1
}

# Install bison-3.8.2
install_bison() {
    printf "\033[32m[ bison-3.8.2 ] installation ...\033[0m\n" || exit 1
    tar -xvf bison-3.8.2.tar.xz && \
    cd bison-3.8.2 && \
    ./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2 && \
    make && make install && \
    cd $LFS/sources && rm -rf bison-3.8.2 && \
    printf "\033[32m[ bison-3.8.2 ] installation successful\033[0m\n" || exit 1
}

# Install perl-5.38.2
install_perl() {
    printf "\033[32m[ perl-5.38.2 ] installation ...\033[0m\n" || exit 1
    tar -xvf perl-5.38.2.tar.xz && \
    cd perl-5.38.2 && \
    sh Configure -des                                    \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Duseshrplib                                \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl     \
             -Darchlib=/usr/lib/perl5/5.38/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl && \
    make && make install && \
    cd $LFS/sources && rm -rf perl-5.38.2 && \
    printf "\033[32m[ perl-5.38.2 ] installation successful\033[0m\n" || exit 1
}

# Install Python-3.12.2.tar.xz
install_python() {
    printf "\033[32m[ Python-3.12.2 ] installation ...\033[0m\n" || exit 1
    tar -xvf Python-3.12.2.tar.xz && \
    cd Python-3.12.2 && \
    ./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip && \
    make && make install && \
    cd $LFS/sources && rm -rf Python-3.12.2 && \
    printf "\033[32m[ Python-3.12.2 ] installation successful\033[0m\n" || exit 1
}

# Install texinfo-7.1.tar.xz
install_texinfo() {
    printf "\033[32m[ texinfo-7.1 ] installation ...\033[0m\n" || exit 1
    tar -xvf texinfo-7.1.tar.xz && \
    cd texinfo-7.1 && \
    ./configure --prefix=/usr && \
    make && make install && \
    cd $LFS/sources && rm -rf texinfo-7.1 && \
    printf "\033[32m[ texinfo-7.1 ] installation successful\033[0m\n" || exit 1
}

# Install util-linux-2.39.3.tar.xz
install_util_linux() {
    printf "\033[32m[ util-linux-2.39.3 ] installation ...\033[0m\n" || exit 1
    tar -xvf util-linux-2.39.3.tar.xz && \
    cd util-linux-2.39.3 && \
    mkdir -pv /var/lib/hwclock && \
    ./configure --libdir=/usr/lib    \
            --runstatedir=/run   \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.39.3 && \
    make && make install && \
    cd $LFS/sources && rm -rf util-linux-2.39.3 && \
    printf "\033[32m[ util-linux-2.39.3 ] installation successful\033[0m\n" || exit 1
}

clean_up() {
    rm -rf /usr/share/{info,man,doc}/* && \
    find /usr/{lib,libexec} -name \*.la -delete && \
    rm -rf /tools || exit 1
}

install_gettext
install_bison
install_perl
install_python
install_texinfo
install_util_linux
clean_up

printf "\033[36[m[ SUCCESS ] Additional tools are built successfully\033[0m\n"