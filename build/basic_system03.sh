#!/bin/bash

# autoconf-2.72
printf "\033[32m[ autoconf-2.72 ] installation ...\033[0m\n" || exit 1
tar -xvf autoconf-2.72.tar.xz && \
cd autoconf-2.72 && \
./configure --prefix=/usr && \
make && make check && \
make install && \
cd /sources && rm -rf autoconf-2.72 && \
printf "\033[32m[ autoconf-2.72 ] installation successful\033[0m\n" || exit 1

# automake-1.16.5
printf "\033[32m[ automake-1.16.5 ] installation ...\033[0m\n" || exit 1
tar -xvf automake-1.16.5.tar.xz && \
cd automake-1.16.5 && \
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5 && \
make && make -j$(($(nproc)>4?$(nproc):4)) check && \
make install && \
cd /sources && rm -rf automake-1.16.5 && \
printf "\033[32m[ automake-1.16.5 ] installation successful\033[0m\n" || exit 1

# openssl-3.2.1
printf "\033[32m[ openssl-3.2.1 ] installation ...\033[0m\n" || exit 1
tar -xvf openssl-3.2.1.tar.gz && \
cd openssl-3.2.1 && \
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic && \
make && HARNESS_JOBS=$(nproc) make test && \
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile && \
make MANSUFFIX=ssl install && \
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.2.1 && \
cp -vfr doc/* /usr/share/doc/openssl-3.2.1 &&\
cd /sources && rm -rf openssl-3.2.1 && \
printf "\033[32m[ openssl-3.2.1 ] installation successful\033[0m\n" || exit 1

# kmod-31
printf "\033[32m[ kmod-31 ] installation ...\033[0m\n" || exit 1
tar -xvf kmod-31.tar.xz && \
cd kmod-31 && \
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-openssl         \
            --with-xz              \
            --with-zstd            \
            --with-zlib && \
make && make install && \
for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
done && \
ln -sfv kmod /usr/bin/lsmod && \
cd /sources && rm -rf kmod-31 && \
printf "\033[32m[ kmod-31 ] installation successful\033[0m\n" || exit 1

# elfutils-0.190
printf "\033[32m[ elfutils-0.190 ] installation ...\033[0m\n" || exit 1
tar -xvf elfutils-0.190.tar.bz2 && \
cd elfutils-0.190 && \
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy && \
make && make check && \
make -C libelf install && \
install -vm644 config/libelf.pc /usr/lib/pkgconfig && \
rm /usr/lib/libelf.a && \
cd /sources && rm -rf elfutils-0.190 && \
printf "\033[32m[ elfutils-0.190 ] installation successful\033[0m\n" || exit 1

# libffi-3.4.4
printf "\033[32m[ libffi-3.4.4 ] installation ...\033[0m\n" || exit 1
tar -xvf libffi-3.4.4.tar.gz && \
cd libffi-3.4.4 && \
./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native && \
make && make check && \
make install && \
cd /sources && rm -rf libffi-3.4.4 && \
printf "\033[32m[ libffi-3.4.4 ] installation successful\033[0m\n" || exit 1

# Python-3.12.2
printf "\033[32m[ Python-3.12.2 ] installation ...\033[0m\n" || exit 1
tar -xvf Python-3.12.2.tar.xz && \
cd Python-3.12.2 && \
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations && \
make && make install && \
cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF 
install -v -dm755 /usr/share/doc/python-3.12.2/html && \
tar --no-same-owner \
    -xvf ../python-3.12.2-docs-html.tar.bz2 && \
cp -R --no-preserve=mode python-3.12.2-docs-html/* \
    /usr/share/doc/python-3.12.2/html && \
cd /sources && rm -rf Python-3.12.2 && \
printf "\033[32m[ Python-3.12.2 ] installation successful\033[0m\n" || exit 1

# flit_core-3.9.0
printf "\033[32m[ flit_core-3.9.0 ] installation ...\033[0m\n" || exit 1
tar -xvf flit_core-3.9.0.tar.gz && \
cd flit_core-3.9.0 && \
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD && \
pip3 install --no-index --no-user --find-links dist flit_core && \
cd /sources && rm -rf flit_core-3.9.0 && \
printf "\033[32m[ flit_core-3.9.0 ] installation successful\033[0m\n" || exit 1

# wheel-0.42.0
printf "\033[32m[ wheel-0.42.0 ] installation ...\033[0m\n" || exit 1
tar -xvf wheel-0.42.0.tar.gz && \
cd wheel-0.42.0 && \
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD && \
pip3 install --no-index --find-links=dist wheel && \
cd /sources && rm -rf wheel-0.42.0 && \
printf "\033[32m[ wheel-0.42.0 ] installation successful\033[0m\n" || exit 1

# setuptools-69.1.0
printf "\033[32m[ setuptools-69.1.0 ] installation ...\033[0m\n" || exit 1
tar -xvf setuptools-69.1.0.tar.gz && \
cd setuptools-69.1.0 && \
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD && \
pip3 install --no-index --find-links dist setuptools && \
cd /sources && rm -rf setuptools-69.1.0 && \
printf "\033[32m[ setuptools-69.1.0 ] installation successful\033[0m\n" || exit 1

# ninja-1.11.1
printf "\033[32m[ ninja-1.11.1 ] installation ...\033[0m\n" || exit 1
tar -xvf ninja-1.11.1.tar.gz && \
cd ninja-1.11.1 && \
export NINJAJOBS=4 && \
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc && \
python3 configure.py --bootstrap && \
./ninja ninja_test && \
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots && \
install -vm755 ninja /usr/bin/ && \
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja && \
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja && \
cd /sources && rm -rf ninja-1.11.1 && \
printf "\033[32m[ ninja-1.11.1 ] installation successful\033[0m\n" || exit 1

# meson-1.3.2
printf "\033[32m[ meson-1.3.2 ] installation ...\033[0m\n" || exit 1
tar -xvf meson-1.3.2.tar.gz && \
cd meson-1.3.2 && \
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD && \
pip3 install --no-index --find-links dist meson && \
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson && \
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson && \
cd /sources && rm -rf meson-1.3.2 && \
printf "\033[32m[ meson-1.3.2 ] installation successful\033[0m\n" || exit 1

# coreutils-9.4
printf "\033[32m[ coreutils-9.4 ] installation ...\033[0m\n" || exit 1
tar -xvf coreutils-9.4.tar.xz && \
cd coreutils-9.4 && \
patch -Np1 -i ../coreutils-9.4-i18n-1.patch && \
sed -e '/n_out += n_hold/,+4 s|.*bufsize.*|//&|' \
    -i src/split.c && \
autoreconf -fiv && 
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime || exit 1
make && make NON_ROOT_USERNAME=tester check-root && \
groupadd -g 102 dummy -U tester && \
chown -R tester . && \
su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check" && \
groupdel dummy && \
make install && \
mv -v /usr/bin/chroot /usr/sbin && \
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8 && \
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8 && \
cd /sources && rm -rf coreutils-9.4 && \
printf "\033[32m[ coreutils-9.4 ] installation successful\033[0m\n" || exit 1

# check-0.15.2
printf "\033[32m[ check-0.15.2 ] installation ...\033[0m\n" || exit 1
tar -xvf check-0.15.2.tar.gz && \
cd check-0.15.2 && \
./configure --prefix=/usr --disable-static && \
make && make check && \
make docdir=/usr/share/doc/check-0.15.2 install && \
cd /sources && rm -rf check-0.15.2 && \
printf "\033[32m[ check-0.15.2 ] installation successful\033[0m\n" || exit 1

# diffutils-3.10
printf "\033[32m[ diffutils-3.10 ] installation ...\033[0m\n" || exit 1
tar -xvf diffutils-3.10.tar.xz && \
cd diffutils-3.10 && \
./configure --prefix=/usr --disable-static && \
make && make check && \
make docdir=/usr/share/doc/diffutils-3.10 install && \
cd /sources && rm -rf diffutils-3.10 && \
printf "\033[32m[ diffutils-3.10 ] installation successful\033[0m\n" || exit 1

# gawk-5.3.0
printf "\033[32m[ gawk-5.3.0 ] installation ...\033[0m\n" || exit 1
tar -xvf gawk-5.3.0.tar.xz && \
cd gawk-5.3.0 && \
sed -i 's/extras//' Makefile.in && \
./configure --prefix=/usr && \
make && chown -R tester . && \
su tester -c "PATH=$PATH make check" && \
rm -f /usr/bin/gawk-5.3.0 && \
make install && \
ln -sv gawk.1 /usr/share/man/man1/awk.1 && \
mkdir -pv  /usr/share/doc/gawk-5.3.0 && \
cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.3.0 && \
cd /sources && rm -rf gawk-5.3.0 && \
printf "\033[32m[ gawk-5.3.0 ] installation successful\033[0m\n" || exit 1

# findutils-4.9.0
printf "\033[32m[ findutils-4.9.0 ] installation ...\033[0m\n" || exit 1
tar -xvf findutils-4.9.0.tar.xz && \
cd findutils-4.9.0 && \
./configure --prefix=/usr --localstatedir=/var/lib/locate && \
make && chown -R tester . && \
su tester -c "PATH=$PATH make check" && \
make install && \
cd /sources && rm -rf findutils-4.9.0 && \
printf "\033[32m[ findutils-4.9.0 ] installation successful\033[0m\n" || exit 1

# groff-1.23.0
printf "\033[32m[ groff-1.23.0 ] installation ...\033[0m\n" || exit 1
tar -xvf groff-1.23.0.tar.gz && \
cd groff-1.23.0 && \
PAGE=A4 ./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf groff-1.23.0 && \
printf "\033[32m[ groff-1.23.0 ] installation successful\033[0m\n" || exit 1

# grub-2.12
printf "\033[32m[ grub-2.12 ] installation ...\033[0m\n" || exit 1
tar -xvf grub-2.12.tar.xz && \
cd grub-2.12 && \
# check TUT
# unset {C,CPP,CXX,LD}FLAGS && \
echo depends bli part_gpt > grub-core/extra_deps.lst && \
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror && \
make && make install && \
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions && \
cd /sources && rm -rf grub-2.12 && \
printf "\033[32m[ grub-2.12 ] installation successful\033[0m\n" || exit 1

# gzip-1.13
printf "\033[32m[ gzip-1.13 ] installation ...\033[0m\n" || exit 1
tar -xvf gzip-1.13.tar.xz && \
cd gzip-1.13 && \
./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf gzip-1.13 && \
printf "\033[32m[ gzip-1.13 ] installation successful\033[0m\n" || exit 1

# iproute2-6.7.0
printf "\033[32m[ iproute2-6.7.0 ] installation ...\033[0m\n" || exit 1
tar -xvf iproute2-6.7.0.tar.xz && \
cd iproute2-6.7.0 && \
sed -i /ARPD/d Makefile && \
rm -fv man/man8/arpd.8 && \
make NETNS_RUN_DIR=/run/netns && \
make SBINDIR=/usr/sbin install && \
mkdir -pv /usr/share/doc/iproute2-6.7.0 && \
cp -v COPYING README* /usr/share/doc/iproute2-6.7.0 && \
cd /sources && rm -rf iproute2-6.7.0 && \
printf "\033[32m[ iproute2-6.7.0 ] installation successful\033[0m\n" || exit 1

# kbd-2.6.4
printf "\033[32m[ kbd-2.6.4 ] installation ...\033[0m\n" || exit 1
tar -xvf kbd-2.6.4.tar.xz && \
cd kbd-2.6.4 && \
patch -Np1 -i ../kbd-2.6.4-backspace-1.patch && \
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure && \
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in && \
./configure --prefix=/usr --disable-vlock && \
make && make check && make install && \
cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.4 && \
cd /sources && rm -rf kbd-2.6.4 && \
printf "\033[32m[ kbd-2.6.4 ] installation successful\033[0m\n" || exit 1

# libpipeline-1.5.7
printf "\033[32m[ libpipeline-1.5.7 ] installation ...\033[0m\n" || exit 1
tar -xvf libpipeline-1.5.7.tar.gz && \
cd libpipeline-1.5.7 && \
./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf libpipeline-1.5.7 && \
printf "\033[32m[ libpipeline-1.5.7 ] installation successful\033[0m\n" || exit 1

# make-4.4.1
printf "\033[32m[ make-4.4.1 ] installation ...\033[0m\n" || exit 1
tar -xvf make-4.4.1.tar.gz && \
cd make-4.4.1 && \
make && chown -R tester . && \
su tester -c "PATH=$PATH make check" && \
make install && \
cd /sources && rm -rf make-4.4.1 && \
printf "\033[32m[ make-4.4.1 ] installation successful\033[0m\n" || exit 1

# patch-2.7.6
printf "\033[32m[ patch-2.7.6 ] installation ...\033[0m\n" || exit 1
tar -xvf patch-2.7.6.tar.xz && \
cd patch-2.7.6 && \
./configure --prefix=/usr && \
make && make check && make install && \
cd /sources && rm -rf patch-2.7.6 && \
printf "\033[32m[ patch-2.7.6 ] installation successful\033[0m\n" || exit 1

# tar-1.35
printf "\033[32m[ tar-1.35 ] installation ...\033[0m\n" || exit 1
tar -xvf tar-1.35.tar.xz && \
cd tar-1.35 && \
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr && \
make && make check && make install && \
make -C doc install-html docdir=/usr/share/doc/tar-1.35 && \
cd /sources && rm -rf tar-1.35 && \
printf "\033[32m[ tar-1.35 ] installation successful\033[0m\n" || exit 1

# texinfo-7.1
printf "\033[32m[ texinfo-7.1 ] installation ...\033[0m\n" || exit 1
tar -xvf texinfo-7.1.tar.xz && \
cd texinfo-7.1 && \
./configure --prefix=/usr && \
make && make check && make install && \
make TEXMF=/usr/share/texmf install-tex && \
pushd /usr/share/info && \
  rm -v dir && \
  for f in *
    do install-info $f dir 2>/dev/null
  done && \
popd && \
cd /sources && rm -rf texinfo-7.1 && \
printf "\033[32m[ texinfo-7.1 ] installation successful\033[0m\n" || exit 1

# vim-9.1.0041
printf "\033[32m[ vim-9.1.0041 ] installation ...\033[0m\n" || exit 1
tar -xvf vim-9.1.0041.tar.gz && \
cd vim-9.1.0041 && \
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h && \
./configure --prefix=/usr && \
make &&  chown -R tester . && \
su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
   &> vim-test.log && \
make install && \
ln -sv vim /usr/bin/vi && \
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done && \
ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.0041 || exit 1
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
cd /sources && rm -rf vim-9.1.0041 && \
printf "\033[32m[ vim-9.1.0041 ] installation successful\033[0m\n" || exit 1

# MarkupSafe-2.1.5
printf "\033[32m[ MarkupSafe-2.1.5 ] installation ...\033[0m\n" || exit 1
tar -xvf MarkupSafe-2.1.5.tar.gz && \
cd MarkupSafe-2.1.5 && \
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD && \
pip3 install --no-index --no-user --find-links dist Markupsafe && \
cd /sources && rm -rf MarkupSafe-2.1.5 && \
printf "\033[32m[ MarkupSafe-2.1.5 ] installation successful\033[0m\n" || exit 1

# Jinja2-3.1.3
printf "\033[32m[ Jinja2-3.1.3 ] installation ...\033[0m\n" || exit 1
tar -xvf Jinja2-3.1.3.tar.gz && \
cd Jinja2-3.1.3 && \
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD && \
pip3 install --no-index --no-user --find-links dist Jinja2 && \
cd /sources && rm -rf Jinja2-3.1.3 && \
printf "\033[32m[ Jinja2-3.1.3 ] installation successful\033[0m\n" || exit 1