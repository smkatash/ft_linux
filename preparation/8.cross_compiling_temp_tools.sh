#!/bin/bash
if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ ERROR ] LFS variable not set. Exiting...\033[0m\n"
	exit 1
else
	printf "\033[32m[ SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

# Install m4-1.4.19
install_m4() {
    printf "\033[32m[ m4-1.4.19 ] installation ...\033[0m\n" || exit 1
    tar -xvf m4-1.4.19.tar.xz && \
    cd m4-1.4.19 && \
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf m4-1.4.19 && \
    printf "\033[32m[ m4-1.4.19 ] installation successful\033[0m\n" || exit 1
}

# Install ncurses-6.4-20230520
install_ncurses() {
    printf "\033[32m[ ncurses-6.4-20230520 ] installation ...\033[0m\n" || exit 1
    tar -xvf ncurses-6.4-20230520.tar.xz && \
    cd ncurses-6.4-20230520 && \
    sed -i s/mawk// configure && \
    mkdir build && \
    pushd build && \
      ../configure && \
      make -C include && \
      make -C progs tic && \
    popd && \
    ./configure --prefix=/usr                \
                --host=$LFS_TGT              \
                --build=$(./config.guess)    \
                --mandir=/usr/share/man      \
                --with-manpage-format=normal \
                --with-shared                \
                --without-normal             \
                --with-cxx-shared            \
                --without-debug              \
                --without-ada                \
                --disable-stripping          \
                --enable-widec && \
    make && make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install && \
    ln -sv libncursesw.so $LFS/usr/lib/libncurses.so && \
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i $LFS/usr/include/curses.h && \
    cd $LFS/sources && rm -rf ncurses-6.4-20230520 && \
    printf "\033[32m[ ncurses-6.4-20230520 ] installation successful\033[0m\n" || exit 1
}

# Install bash-5.2.21
install_bash() {
    printf "\033[32m[ bash-5.2.21 ] installation ...\033[0m\n" || exit 1
    tar -xvf bash-5.2.21.tar.gz && \
    cd bash-5.2.21 && \
    ./configure --prefix=/usr                      \
                --build=$(sh support/config.guess) \
                --host=$LFS_TGT                    \
                --without-bash-malloc && \
    make && make DESTDIR=$LFS install && \
    ln -sv bash $LFS/bin/sh && \
    cd $LFS/sources && rm -rf bash-5.2.21 && \
    printf "\033[32m[ bash-5.2.21 ] installation successful\033[0m\n" || exit 1
}

# Install coreutils-9.4
install_coreutils() {
    printf "\033[32m[ coreutils-9.4 ] installation ...\033[0m\n" || exit 1
    tar -xvf coreutils-9.4.tar.xz && \
    cd coreutils-9.4 && \
    make && make DESTDIR=$LFS install && \
    mv -v $LFS/usr/bin/chroot $LFS/usr/sbin && \
    mkdir -pv $LFS/usr/share/man/man8 && \
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8 && \
    sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8 && \
    cd $LFS/sources && rm -rf coreutils-9.4 && \
    printf "\033[32m[ coreutils-9.4 ] installation successful\033[0m\n" || exit 1
}

# Install diffutils-3.10
install_diffutils() {
    printf "\033[32m[ diffutils-3.10 ] installation ...\033[0m\n" || exit 1
    tar -xvf diffutils-3.10.tar.xz && \
    cd diffutils-3.10 && \
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(./build-aux/config.guess) && \
    make &&  make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf diffutils-3.10 && \
    printf "\033[32m[ diffutils-3.10 ] installation successful\033[0m\n" || exit 1
}

# Install file-5.45
install_file() {
    printf "\033[32m[ file-5.45 ] installation ...\033[0m\n" || exit 1
    tar -xvf file-5.45.tar.gz && \
    cd file-5.45 && \
    mkdir build && \
    pushd build && \
      ../configure --disable-bzlib      \
                   --disable-libseccomp \
                   --disable-xzlib      \
                   --disable-zlib && \
      make && \
    popd && \
    ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) && \
    make FILE_COMPILE=$(pwd)/build/src/file && \
    make DESTDIR=$LFS install && \
    rm -v $LFS/usr/lib/libmagic.la && \
    cd $LFS/sources && rm -rf file-5.45 && \
    printf "\033[32m[ file-5.45 ] installation successful\033[0m\n" || exit 1
}

# Install findutils-4.9.0
install_findutils() {
    printf "\033[32m[ findutils-4.9.0 ] installation ...\033[0m\n" || exit 1
    tar -xvf findutils-4.9.0.tar.xz && \
    cd findutils-4.9.0 && \
    ./configure --prefix=/usr                   \
                --localstatedir=/var/lib/locate \
                --host=$LFS_TGT                 \
                --build=$(build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf findutils-4.9.0 && \
    printf "\033[32m[ findutils-4.9.0 ] installation successful\033[0m\n" || exit 1
}

# Install gawk-5.3.0
install_gawk() {
    printf "\033[32m[ gawk-5.3.0 ] installation ...\033[0m\n" || exit 1
    tar -xvf gawk-5.3.0.tar.xz && \
    cd gawk-5.3.0 && \
    sed -i 's/extras//' Makefile.in && \
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf gawk-5.3.0 && \
    printf "\033[32m[ gawk-5.3.0 ] installation successful\033[0m\n" || exit 1
}

# Install grep-3.11
install_grep() {
    printf "\033[32m[ grep-3.11 ] installation ...\033[0m\n" || exit 1
    tar -xvf grep-3.11.tar.xz && \
    cd grep-3.11 && \
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(./build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf grep-3.11 && \
    printf "\033[32m[ grep-3.11 ] installation successful\033[0m\n" || exit 1
}

# Install gzip-1.13
install_gzip() {
    printf "\033[32m[ gzip-1.13 ] installation ...\033[0m\n" || exit 1
    tar -xvf gzip-1.13.tar.xz && cd gzip-1.13 && \
    ./configure --prefix=/usr --host=$LFS_TGT && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf gzip-1.13 && \
    printf "\033[32m[ gzip-1.13 ] installation successful\033[0m\n" || exit 1
}

# Install make-4.4.1
install_make() {
    printf "\033[32m[ make-4.4.1 ] installation ...\033[0m\n" || exit 1
    tar -xvf make-4.4.1.tar.gz && cd make-4.4.1 && \
    ./configure --prefix=/usr   \
                --without-guile \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf make-4.4.1 && \
    printf "\033[32m[ make-4.4.1 ] installation successful\033[0m\n" || exit 1
}

# Install patch-2.7.6
install_patch() {
    printf "\033[32m[ patch-2.7.6 ] installation ...\033[0m\n" || exit 1
    tar -xvf patch-2.7.6.tar.xz && cd patch-2.7.6 && \
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf patch-2.7.6 && \
    printf "\033[32m[ patch-2.7.6 ] installation successful\033[0m\n" || exit 1
}

# Install sed-4.9
install_sed() {
    printf "\033[32m[ sed-4.9 ] installation ...\033[0m\n" || exit 1
    tar -xvf sed-4.9.tar.xz && cd sed-4.9 && \
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(./build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf sed-4.9 && \
    printf "\033[32m[ sed-4.9 ] installation successful\033[0m\n" || exit 1
}

# Install tar-1.35
install_tar() {
    printf "\033[32m[ tar-1.35 ] installation ...\033[0m\n" || exit 1
    tar -xvf tar-1.35.tar.xz && cd tar-1.35 && \
    ./configure --prefix=/usr                     \
                --host=$LFS_TGT                   \
                --build=$(build-aux/config.guess) && \
    make && make DESTDIR=$LFS install && \
    cd $LFS/sources && rm -rf tar-1.35 && \
    printf "\033[32m[ tar-1.35 ] installation successful\033[0m\n" || exit 1
}

# Install xz-5.4.6
install_xz() {
    printf "\033[32m[ xz-5.4.6 ] installation ...\033[0m\n" || exit 1
    tar -xvf xz-5.4.6.tar.xz && cd xz-5.4.6 && \
    ./configure --prefix=/usr                     \
                --host=$LFS_TGT                   \
                --build=$(build-aux/config.guess) \
                --disable-static                  \
                --docdir=/usr/share/doc/xz-5.4.6 && \
    make && make DESTDIR=$LFS install && rm -v $LFS/usr/lib/liblzma.la && \
    cd $LFS/sources && rm -rf xz-5.4.6 && \
    printf "\033[32m[ xz-5.4.6 ] installation successful\033[0m\n" || exit 1
}

# Install binutils-2.42
install_binutils() {
    printf "\033[32m[ binutils-2.42 ] installation ...\033[0m\n" || exit 1
    tar -xvf binutils-2.42.tar.xz && cd binutils-2.42 && \
    sed '6009s/$add_dir//' -i ltmain.sh && \
    mkdir -v build && cd build && \
    ../configure                   \
        --prefix=/usr              \
        --build=$(../config.guess) \
        --host=$LFS_TGT            \
        --disable-nls              \
        --enable-shared            \
        --enable-gprofng=no        \
        --disable-werror           \
        --enable-64-bit-bfd        \
        --enable-default-hash-style=gnu && \
    make && make DESTDIR=$LFS install && \
    rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la} && \
    cd $LFS/sources && rm -rf binutils-2.42 && \
    printf "\033[32m[ binutils-2.42 ] installation successful\033[0m\n" || exit 1
}

# Install gcc-13.2.0
install_gcc() {
    printf "\033[32m[ gcc-13.2.0 ] installation ...\033[0m\n" || exit 1
    tar -xvf gcc-13.2.0.tar.xz && cd gcc-13.2.0 && \
    tar -xf ../mpfr-4.2.1.tar.xz && \
    mv -v mpfr-4.2.1 mpfr && \
    tar -xf ../gmp-6.3.0.tar.xz && \
    mv -v gmp-6.3.0 gmp && \
    tar -xf ../mpc-1.3.1.tar.gz && \
    mv -v mpc-1.3.1 mpc && \
    case $(uname -m) in
      x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64 
      ;;
    esac && \
    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
        -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in && \
    mkdir -v build && cd build && \
    ../configure                                       \
        --build=$(../config.guess)                     \
        --host=$LFS_TGT                                \
        --target=$LFS_TGT                              \
        LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
        --prefix=/usr                                  \
        --with-build-sysroot=$LFS                      \
        --enable-default-pie                           \
        --enable-default-ssp                           \
        --disable-nls                                  \
        --disable-multilib                             \
        --disable-libatomic                            \
        --disable-libgomp                              \
        --disable-libquadmath                          \
        --disable-libsanitizer                         \
        --disable-libssp                               \
        --disable-libvtv                               \
        --enable-languages=c,c++ && \
    make && make DESTDIR=$LFS install && \
    ln -sv gcc $LFS/usr/bin/cc && \
    cd $LFS/sources && rm -rf gcc-13.2.0 && \
    printf "\033[32m[ gcc-13.2.0 ] installation successful\033[0m\n" || exit 1
}

# install packages
install_m4
install_ncurses
install_bash
install_coreutils
install_diffutils
install_file
install_findutils
install_gawk
install_grep
install_gzip
install_make
install_patch
install_sed
install_tar
install_xz
install_binutils
install_gcc

printf "\033[36[m[ SUCCESS ] Temporary tools compiled\033[0m\n"