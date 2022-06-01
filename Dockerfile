FROM        ubuntu:22.04
ARG         DEBIAN_FRONTEND=noninteractive
LABEL       maintainer="eronur@metu.edu.tr"
LABEL       version="2.1.1"
LABEL       description="This is the AHC docker image"

RUN         apt update && apt upgrade -yf && apt clean && apt autoremove
RUN         apt install -y tzdata git git-core  wget zip unzip autoconf automake build-essential doxygen cmake g++  curl dpdk dpdk-dev libdpdk-dev python3-dev  python3-mako python3-numpy python3-requests python3-scipy python3-setuptools python3-ruamel.yaml python3-dev python3-docutils python3-gi python3-gi-cairo python3-gps python3-lxml python3-numpy python3-opengl python3-pyqt5 python3-setuptools python3-six python3-sphinx python3-yaml python3-zmq swig pkg-config libboost-all-dev libzmq3-dev  libusb-1.0-0 libusb-1.0-0-dev libusb-dev zlib1g-dev libncurses5 libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev ccache cpufrequtils doxygen ethtool inetutils-tools  ethtool fort77 g++ gir1.2-gtk-3.0  gobject-introspection gpsd gpsd-clients inetutils-tools libasound2-dev  libcomedi-dev libcppunit-dev libfftw3-bin libfftw3-dev libfftw3-doc libfontconfig1-dev libgmp-dev libgps-dev libgsl-dev liblog4cpp5-dev libncurses5 libncurses5-dev libpulse-dev libqt5opengl5-dev libqwt-qt5-dev libsdl1.2-dev libtool libudev-dev libusb-1.0-0 libusb-1.0-0-dev libusb-dev libxi-dev libxrender-dev libzmq3-dev libzmq5 ncurses-bin  swig wget python3-pip python3-cheetah python3-click python3-click-plugins python3-click-threading python3-gevent python3-pyudev python3-virtualenv python3-pyroute2 python3-numpy python3-mako python3-requests python3-six python3-pyqt5 python3-pyqtgraph nano vim
RUN         pip3 install networkx matplotlib mnist numpy pandas


ARG         MAKEWIDTH=8
ARG         UHD_TAG=v4.2.0.0

RUN         mkdir -p /usr/local/src \
            && git clone https://github.com/EttusResearch/uhd.git /usr/local/src/uhd

WORKDIR     /usr/local/src/uhd/
RUN         git tag -l \
            && git checkout $UHD_TAG \
            && git submodule update \
            && mkdir -p /usr/local/src/uhd/host/build
# -DENABLE_DPDK=OFF
WORKDIR     /usr/local/src/uhd/host/build
RUN         cmake ..  -DENABLE_PYTHON_API=ON -DUHD_RELEASE_MODE=release -DCMAKE_INSTALL_PREFIX=/usr \
            && make -j $MAKEWIDTH \
            && make install \
            && ldconfig \
            && uhd_images_downloader

WORKDIR     /usr/lib/uhd/utils
RUN         cp uhd-usrp.rules /etc/udev/rules.d/
ENV         UHD_IMAGES_DIR=/usr/share/uhd/images

WORKDIR     /usr/local/src
RUN         git clone https://github.com/cengwins/liquid-dsp.git /usr/local/src/liquid-dsp
#RUN         cd /usr/local/src/liquid-dsp
WORKDIR     /usr/local/src/liquid-dsp
RUN         ./bootstrap.sh  \
            && ./configure \
            && make -j $MAKEWIDTH \
            && make install \
            && ldconfig

WORKDIR     /usr/local/src/
RUN	   apt install -y python3-six python3-six python-six python3-mako python3-lxml python3-lxml python3-numpy python3-numpy python3-pip git python3-pybind11 libsndfile1-dev libusb-1.0-0-dev libusb-1.0-0 build-essential cmake libncurses5-dev libtecla1 libtecla-dev pkg-config git wget
RUN	    git clone https://github.com/Nuand/bladeRF.git /usr/local/src/bladeRF
WORKDIR	    /usr/local/src/bladeRF/host
RUN         mkdir build
WORKDIR    /usr/local/src/bladeRF/host/build
RUN        cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON .. \
           && groupadd bladerf \
           && usermod -a -G bladerf root \
           && make && make install && ldconfig 
WORKDIR    /usr/local/src/bladeRF/host/libraries/libbladeRF_bindings/python
RUN	   pip install .
WORKDIR    /etc
RUN	   mkdir Nuand && cd Nuand && mkdir bladeRF && cd bladeRF && wget https://www.nuand.com/fpga/v0.11.1/hostedx115.rbf 
WORKDIR    /usr/local/src
RUN 	   git clone https://github.com/cengwins/bladerfconfig.git \
	   && cp bladerfconfig/*.tbl /etc/Nuand/bladeRF


WORKDIR     /usr/local/src/
RUN         git clone https://github.com/cengwins/ahc_v2_tests.git /usr/local/src/ahc_v2_tests
WORKDIR     /usr/local/src/ahc_v2_tests
