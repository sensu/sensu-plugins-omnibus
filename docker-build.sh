#!/bin/bash

install_dependencies() {
    if [ "$PLATFORM" = "ubuntu" ]; then
	apt-get update
	apt-get install -y build-essential curl fakeroot
    elif [ "$PLATFORM" = "centos" ]; then
	yum -y install gcc perl rpm-build
    fi
}

install_toolchain() {
    export TOOLCHAIN_VERSION=1.1.77
    export TOOLCHAIN_BUILD_NUMBER=1
    export TOOLCHAIN_BASE_URL=https://packages.chef.io/files/stable/omnibus-toolchain/${TOOLCHAIN_VERSION}

    if [ "$PLATFORM" = "ubuntu" ]; then
	export TOOLCHAIN_FILENAME=omnibus-toolchain_${TOOLCHAIN_VERSION}-${TOOLCHAIN_BUILD_NUMBER}_amd64.deb
	curl -O ${TOOLCHAIN_BASE_URL}/ubuntu/14.04/${TOOLCHAIN_FILENAME}
	dpkg -i ${TOOLCHAIN_FILENAME}
	rm ${TOOLCHAIN_FILENAME}
    elif [ "$PLATFORM" = "centos" ]; then
	rpm -Uvh ${TOOLCHAIN_BASE_URL}/el/6/omnibus-toolchain-${TOOLCHAIN_VERSION}-${TOOLCHAIN_BUILD_NUMBER}.el6.x86_64.rpm
    fi

    source /opt/sensu-plugins-omnibus/load-omnibus-toolchain.sh
}

configure_git() {
    git config --global user.email "justin@sensu.io"
    git config --global user.name "Justin Kolberg"
}

setup_compiler_flags() {
    if [ "$PLATFORM" = "ubuntu" ]; then
	if [ "$KERNEL_ARCH" = "i386" ]; then
	    sudo apt-get install -y gcc-multilib g++-multilib
	    export DEB_ARCH=i386
	    export CFLAGS=-m32
	    export LDFLAGS=-m32
	    export CXXFLAGS=-m32
	    export CPPFLAGS=-m32
	elif [ "$KERNEL_ARCH" = "x86_64" ]; then
	    export DEB_ARCH=amd64
	fi
    fi
}

build_project() {
    cd /opt/sensu-plugins-omnibus
    bundle install
    bundle exec omnibus build sensu_plugins -l debug
}

install_dependencies
install_toolchain
configure_git
setup_compiler_flags
build_project
