#!/bin/bash -e

APT_GET_UPDATE=false

apt_get_update() {
  if [ "$APT_GET_UPDATE" == false ] ; then
    sudo apt-get update
    APT_GET_UPDATE=true
  fi
}

install_package() {
  if [ ! -z "$1" ] && [ $(dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed") -eq 0 ] ; then
     apt_get_update
     sudo apt-get install -y "$1"
  fi
}

install_package "bundler"
install_package "apt-show-versions"
install_package "build-essential"
install_package "libevent-dev"
install_package "git"
install_package "autotools-dev"
install_package "automake"
install_package "pkg-config"
install_package "ncurses-dev"

bundle install

# set default prefix for package version
ORG_PREFIX='xenial'

LIBEVENT_VER=$(apt-show-versions | grep libevent-dev | head -n1 | grep -Po '\d+\.(\d+_)?\d+\.\d+[^\s]+')

WORK_DIR="${PWD}"
BUILD_DIR="${WORK_DIR}/_build"
INSTALL_DIR="${WORK_DIR}/_install"
PKG_DIR="${WORK_DIR}/_pkg"
# I know about nproc, but in openvz it fails.
CPU_COUNT=`grep processor /proc/cpuinfo | wc -l`

# prepare workspace
mkdir -p ${BUILD_DIR} ${INSTALL_DIR} ${PKG_DIR}
cd ${BUILD_DIR}

# download tmux source

git clone https://github.com/tmux/tmux.git

if [ -z $(which fpm) ] ; then
  apt_get_update
  sudo gem install fpm
fi

# configure and build tmux
cd tmux

./autogen.sh
./configure --prefix=/usr

make -j${CPU_COUNT}
make install DESTDIR=${INSTALL_DIR}

cd ${INSTALL_DIR}/usr/bin

TMUX_VER=$($INSTALL_DIR/usr/bin/tmux -V | grep -Po '\d+\.\d+')

# create deb package with fpm
cd ${WORK_DIR}
fpm -s dir -t deb -C ${INSTALL_DIR}/ \
    -n tmux -v ${TMUX_VER} \
    --iteration ${ORG_PREFIX} \
    --description 'tmux built from GitHub source' \
    --url 'https://github.com/iancorbitt/dpkg-tmux' \
    -d "libevent-dev = ${LIBEVENT_VER}" \
    -p ${PKG_DIR}/tmux-VERSION_ARCH.deb .