FROM ubuntu:18.04
MAINTAINER jim jimhsu11@gmail.com

ARG USERNAME=username
ARG USERPWD=yourpassword

# debconf to be non-interactive
ENV DEBIAN_FRONTEND noninteractive

# Update and Add User
RUN apt-get update -y \
    && apt-get install -y vim sudo wget \
    && useradd -ms /bin/bash ${USERNAME} \
    && sudo adduser ${USERNAME} sudo \
    && echo ${USERNAME}:${USERPWD} | chpasswd

# xrdp
RUN apt-get update -y \
    && apt-get install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils xrdp \
    && echo xfce4-session > /home/${USERNAME}/.xsession \
    && sed -i "s/^exec.*Xsession$/startxfce4/g" "/etc/xrdp/startwm.sh" \
    && service xrdp restart

# Install Anaconda
RUN wget --quiet https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh -O ~/anaconda.sh \
    && /bin/bash ~/anaconda.sh -b -p /opt/conda \
    && rm ~/anaconda.sh \
    && echo "export PATH=/opt/conda/bin:$PATH" >> /home/${USERNAME}/.bashrc \
    && sudo chown -R ${USERNAME}:${USERNAME} /opt/conda

#-------------------From Nvidia-------------------
# Nvidia install list
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates \
    && curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - \
    && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list \
    && echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
    && apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*
ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-compat-10-0 \
    && ln -s cuda-10.0 /usr/local/cuda \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NCCL_VERSION 2.4.2

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda10.0 \
    && apt-mark hold libnccl2 \
    && rm -rf /var/lib/apt/lists/*

ENV CUDNN_VERSION 7.6.0.64

LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
    && apt-mark hold libcudnn7 \
    && rm -rf /var/lib/apt/lists/*
#-------------------Nvidia End-------------------

# Copy File to /home/${USERNAME}/
COPY tf2.sh /home/${USERNAME}/
COPY test_tf.py /home/${USERNAME}/
