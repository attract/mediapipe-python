# Docker image main https://github.com/google/mediapipe/blob/master/docs/getting_started/install.md#installing-using-docker
FROM ubuntu:20.04

MAINTAINER <mediapipe@google.com>

WORKDIR /io
WORKDIR /mediapipe

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc-8 g++-8 \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        wget \
        unzip \
        nodejs \
        npm \
        python3-dev \
        python3-opencv \
        python3-pip \
        libprotobuf-dev \
        protobuf-compiler \
        libopencv-core-dev \
        libopencv-highgui-dev \
        libopencv-imgproc-dev \
        libopencv-video-dev \
        libopencv-contrib-dev \
        libopencv-calib3d-dev \
        libopencv-features2d-dev \
        software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && apt-get install -y openjdk-8-jdk && \
    apt-get install -y mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev && \
    apt-get install -y mesa-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 --slave /usr/bin/g++ g++ /usr/bin/g++-8
# RUN pip3 install --upgrade setuptools
RUN pip3 install wheel
RUN pip3 install future
RUN pip3 install absl-py numpy opencv-contrib-python protobuf==3.20.1
RUN pip3 install six==1.14.0
RUN pip3 install tensorflow
RUN pip3 install tf_slim
RUN pip3 install rq
RUN pip3 install redis

RUN ln -s /usr/bin/python3 /usr/bin/python

# Install bazel
ARG BAZEL_VERSION=6.1.1
RUN mkdir /bazel && \
    wget --no-check-certificate -O /bazel/installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/b\
azel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    wget --no-check-certificate -O  /bazel/LICENSE.txt "https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE" && \
    chmod +x /bazel/installer.sh && \
    /bazel/installer.sh  && \
    rm -f /bazel/installer.sh

WORKDIR /mediapipe
# Fork official mediapipe (with fixes - https://github.com/google/mediapipe/issues/3491#issuecomment-1354288601)
RUN git clone -b master https://github.com/attract/mediapipe.git
WORKDIR /mediapipe/mediapipe

RUN pip3 install -r requirements.txt
# Option 2 - https://github.com/google/mediapipe/blob/master/docs/getting_started/install.md#installing-on-debian-and-ubuntu
RUN ./setup_opencv.sh
# Building MediaPipe Python Package https://github.com/google/mediapipe/blob/master/docs/getting_started/python.md#building-mediapipe-python-package
RUN python3 setup.py install --link-opencv
# Patch holistic.py file https://github.com/google/mediapipe/issues/3491#issuecomment-1354288601
COPY ./holistic.py /usr/local/lib/python3.8/dist-packages/mediapipe/python/solutions/holistic.py
