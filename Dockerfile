FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
LABEL maintainer="eronur@metu.edu.tr"
LABEL version="0.1"
LABEL description="This is the AHC docker image"

RUN apt update && apt upgrade -yf && apt clean && apt autoremove
RUN apt install -y tzdata
RUN apt install -y git git-core 
RUN apt install -y wget zip unzip 
RUN apt install -y autoconf automake build-essential doxygen
RUN apt install -y cmake 
RUN apt install -y g++ 
RUN apt install -y curl
RUN apt install -y dpdk libdpdk-dev
RUN apt install -y python3-dev  python3-mako python3-numpy python3-requests python3-scipy python3-setuptools python3-ruamel.yaml python3-dev python3-docutils python3-gi python3-gi-cairo python3-gps python3-lxml python3-numpy-dbg python3-opengl python3-pyqt5 python3-setuptools python3-six python3-sphinx python3-yaml python3-zmq 
RUN apt install -y swig pkg-config 
RUN apt install -y libboost-all-dev
RUN apt install -y libzmq3-dev 
RUN apt install -y libusb-1.0-0 libusb-1.0-0-dev libusb-dev
RUN apt install -y zlib1g-dev libncurses5 libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev
RUN apt install -y ccache cpufrequtils doxygen ethtool inetutils-tools 
RUN apt install -y ethtool fort77 g++ gir1.2-gtk-3.0  gobject-introspection gpsd gpsd-clients inetutils-tools libasound2-dev  libcomedi-dev libcppunit-dev libfftw3-bin libfftw3-dev libfftw3-doc libfontconfig1-dev libgmp-dev libgps-dev libgsl-dev liblog4cpp5-dev libncurses5 libncurses5-dev libpulse-dev libqt5opengl5-dev libqwt-qt5-dev libsdl1.2-dev libtool libudev-dev libusb-1.0-0 libusb-1.0-0-dev libusb-dev libxi-dev libxrender-dev libzmq3-dev libzmq5 ncurses-bin  swig wget
RUN apt install -y python3-pip python3-cheetah python3-click python3-click-plugins python3-click-threading
RUN pip3 install gevent pyudev mprpc pyroute2 numpy mako requests six pyqt5 pyqtgraph

#RUN apt install -y software-properties-common
#RUN add-apt-repository ppa:ettusresearch/uhd
#RUN apt-get update 
#RUN apt-get install -y libuhd-dev libuhd3.15.0 uhd-host
#RUN apt-get remove -y libuhd* uhd-host

#ENV uhd_tag release_003_011_000_001
#ENV threads 10
#RUN git clone https://github.com/EttusResearch/uhd.git
#WORKDIR /opt/uhd/host
#RUN git checkout ${uhd_tag}
ARG         MAKEWIDTH=3
ARG         UHD_TAG=v3.15.0.03
#RUN          rm -rf /var/lib/apt/lists/*
RUN          mkdir -p /usr/local/src
RUN          git clone https://github.com/EttusResearch/uhd.git /usr/local/src/uhd
RUN          cd /usr/local/src/uhd/ 
#RUN         git checkout $UHD_TAG
RUN          mkdir -p /usr/local/src/uhd/host/build
WORKDIR      /usr/local/src/uhd/host/build
RUN          cmake .. -DENABLE_PYTHON3=ON -DUHD_RELEASE_MODE=release -DCMAKE_INSTALL_PREFIX=/usr
RUN          make -j $MAKEWIDTH
RUN          make install
RUN          uhd_images_downloader
WORKDIR  /usr/lib/uhd/utils
RUN cp uhd-usrp.rules /etc/udev/rules.d/
#RUN udevadm control --reload-rules
#RUN udevadm trigger
ENV UHD_IMAGES_DIR=/usr/share/uhd/images

RUN git clone https://github.com/cengwins/liquid-dsp.git /usr/local/src/liquid-dsp
RUN cd /usr/local/src/liquid-dsp
WORKDIR /usr/local/src/liquid-dsp
RUN ls -als
RUN ./bootstrap.sh
RUN ./configure
RUN make -j $MAKEWIDTH
RUN make install
RUN ldconfig


RUN pip3 install networkx matplotlib mnist numpy pandas
RUN apt install -y nano vim
#RUN git clone https://github.com/cengwins/ahc.git /usr/local/src/ahc
#WORKDIR /usr/local/src/ahc
#RUN pip3 install git+https://github.com/cengwins/ahc
RUN pip install adhoccomputing
