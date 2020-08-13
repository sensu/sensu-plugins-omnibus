#!/bin/bash

set -e

install_dependencies() {
    echo "Installing dependencies"

    if [ "$PLATFORM" = "ubuntu" ]; then
        apt-get update
        apt-get install -y build-essential curl fakeroot tar git
    elif [ "$PLATFORM" = "centos" ]; then
        yum -y install perl rpm-build make automake gcc gcc-c++ util-linux-ng which
    fi
}

install_toolchain() {
    echo "Installing toolchain"

    export TOOLCHAIN_VERSION=1.1.99
    export TOOLCHAIN_BUILD_NUMBER=1
    export TOOLCHAIN_BASE_URL=https://packages.chef.io/repos

    if [ "$PLATFORM" = "ubuntu" ]; then
        export TOOLCHAIN_FILENAME=omnibus-toolchain_${TOOLCHAIN_VERSION}-${TOOLCHAIN_BUILD_NUMBER}_amd64.deb
        curl -O ${TOOLCHAIN_BASE_URL}/apt/stable/ubuntu/14.04/${TOOLCHAIN_FILENAME}
        dpkg -i ${TOOLCHAIN_FILENAME}
        rm ${TOOLCHAIN_FILENAME}

        # replace omnibus-toolchain tar with system tar
        cp $(which tar) /opt/omnibus-toolchain/embedded/bin/tar
    elif [ "$PLATFORM" = "centos" ]; then
        export TOOLCHAIN_FILENAME=omnibus-toolchain-${TOOLCHAIN_VERSION}-${TOOLCHAIN_BUILD_NUMBER}.el6.x86_64.rpm
        rpm -Uvh ${TOOLCHAIN_BASE_URL}/yum/stable/el/6/x86_64/${TOOLCHAIN_FILENAME}
    fi

    source /opt/sensu-plugins-omnibus/load-omnibus-toolchain.sh
}

configure_git() {
    echo "Configuring git"
    git config --global user.email "justin@sensu.io"
    git config --global user.name "Justin Kolberg"
}

setup_compiler_flags() {
    echo "Setting compiler flags"
    if [ "$PLATFORM" = "ubuntu" ]; then
        if [ "$KERNEL_ARCH" = "i386" ]; then
            apt-get install -y gcc-multilib g++-multilib
            export DEB_ARCH=i386
            export CFLAGS=-m32
            export LDFLAGS=-m32
            export CXXFLAGS=-m32
            export CPPFLAGS=-m32
        elif [ "$KERNEL_ARCH" = "x86_64" ]; then
            export DEB_ARCH=amd64
        fi
    elif [ "$PLATFORM" = "centos" ]; then
        if [ "$KERNEL_ARCH" = "i386" ]; then
            yum -y install glibc-devel.i686 libgcc.i686 libstdc++-devel.i686 ncurses-devel.i686
            export CFLAGS=-m32
            export LDFLAGS=-m32
            export CXXFLAGS=-m32
            export CPPFLAGS=-m32
        elif [ "$KERNEL_ARCH" = "x86_64" ]; then
            yum -y install glibc-devel.x86_64
        fi
    fi
}

install_gem_dependencies() {
    echo "Installing gem dependencies"
    cd /opt/sensu-plugins-omnibus
    rm -rf .bundle
    bundle install
}

build_project() {
    echo "Building project"
    cd /opt/sensu-plugins-omnibus
    bundle exec omnibus build sensu_plugins
}

publish_packages() {
    if [ "x$CIRCLE_TAG" != "x" ]; then
        echo "Publishing packages"
        cd /opt/sensu-plugins-omnibus
        if [ "$PLATFORM" = "ubuntu" ]; then
            bundle exec omnibus publish packagecloud $PACKAGECLOUD_REPO pkg/*.deb
        elif [ "$PLATFORM" = "centos" ]; then
            bundle exec omnibus publish packagecloud $PACKAGECLOUD_REPO pkg/*.rpm
        fi
    else
        echo "CIRCLE_TAG not set, skipping publishing"
    fi
}

case "$1" in
    install_dependencies)
        install_dependencies
        ;;
    install_toolchain)
        install_toolchain
        ;;
    configure_git)
        configure_git
        ;;
    setup_compiler_flags)
        setup_compiler_flags
        ;;
    install_gem_dependencies)
        install_gem_dependencies
        ;;
    build_project)
        build_project
        ;;
    publish_packages)
        publish_packages
        ;;
    *)
        install_dependencies
        install_toolchain
        configure_git
        setup_compiler_flags
        install_gem_dependencies
        build_project
        ;;
esac
