#!/bin/bash

if [ "$(echo $LFS)" = "" ]; then
	export LFS=/mnt/lfs
fi 

if [ "$(echo $LFS)" = "" ]; then
	printf "\033[31m[ ERROR ] LFS variable not set. Exiting...\033[0m\n"
	exit 1
else
	printf "\033[32m[ SUCCESS ] LFS variable was set successfully\033[0m\n"
fi 

cd $LFS/sources || exit 1

# binutils-2.42
printf "\033[32m[ binutils-2.42 ] installation ...\033[0m\n" || exit 1
tar -xvf binutils-2.42.tar.xz && \
cd binutils-2.42 && \
mkdir -v build && cd build && \
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-default-hash-style=gnu && \
make && make install && \
cd .. && \
rm -rf binutils-2.42 && \
printf "\033[32m[ binutils-2.42 ] installation successful\033[0m\n" || exit 1


# gcc-13.2.0
printf "\033[32m[ gcc-13.2.0 ] installation ...\033[0m\n" || exit 1
tar -xvf gcc-13.2.0.tar.xz && \
cd gcc-13.2.0 && \
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

mkdir -v build && cd build && \
../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.39 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++ && \
make && make install && cd .. && \ 
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h && \
cd .. && rm -rf gcc-13.2.0 && \
printf "\033[32m[ gcc-13.2.0 ] installation successful\033[0m\n" || exit 1


# linux-6.7.4.tar.xz 
printf "\033[32m[ linux-6.7.4 ] installation ...\033[0m\n" || exit 1
tar -xvf linux-6.7.4.tar.xz && cd linux-6.7.4 && \
make mrproper && \
make headers && \
find usr/include -type f ! -name '*.h' -delete && \
cp -rv usr/include $LFS/usr && \
cd .. && rm -rf linux-6.7.4 && \ 
printf "\033[32m[ linux-6.7.4 ] installation successful\033[0m\n" || exit 1

# glibc-2.39.tar.xz
printf "\033[32m[ glibc-2.39 ] installation ...\033[0m\n" || exit 1
tar -xvf glibc-2.39.tar.xz && cd glibc-2.39 && \
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac && \
patch -Np1 -i ../glibc-2.39-fhs-1.patch && \
mkdir -v build && cd build && \
echo "rootsbindir=/usr/sbin" > configparms && \
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=4.19               \
      --with-headers=$LFS/usr/include    \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib && \
make && make DESTDIR=$LFS install && \
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd && \
echo 'int main(){}' | $LFS_TGT-gcc -xc - && \
readelf -l a.out | grep ld-linux && \
rm -v a.out && \
cd .. && rm -rf glibc-2.39 && \ 
printf "\033[32m[ glibc-2.39 ] installation successful\033[0m\n" || exit 1

# Libstdc++
printf "\033[32m[ Libstdc++ ] installation ...\033[0m\n" || exit 1
tar -xvf gcc-13.2.0.tar.xz && \
cd gcc-13.2.0 && \
mkdir -v build && cd build && \
../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/13.2.0 && \
make && make DESTDIR=$LFS install && \
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la && \
cd .. && rm -rf gcc-13.2.0 && \
printf "\033[32m[ Libstdc++ ] installation successful\033[0m\n" || exit 1


printf "\033[36[m[ SUCCESS ] Cross Toolchain compiled\033[0m\n"

