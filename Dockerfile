FROM debian:jessie
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Base dependencies
RUN apt-get update && apt-get install -y \
        binutils \
        build-essential \
        bzip2 \
        ca-certificates \
        curl \
        git \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup Tini
ENV TINI_VERSION v0.13.2
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Setup nodejs
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install -y \
        nodejs \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup conda
ENV MINICONDA_VERSION 4.2.12
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    curl -k -o /miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh && \
    /bin/bash /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh && \
    /opt/conda/bin/conda config \
        --set always_yes yes \
        --set changeps1 no \
        --set show_channel_urls True \
        && \
    /opt/conda/bin/conda config \
        --add channels conda-forge \
        --add channels axiom-data-science \
        && \
    /opt/conda/bin/conda clean -a -y
ENV PATH /opt/conda/bin:$PATH

WORKDIR /srv/everware/
# Copy npm and python requirements to cache the layer
COPY requirements.txt /srv/everware/requirements.txt
COPY package.json /srv/everware/package.json
RUN npm install -g configurable-http-proxy && \
    npm install && \
    pip install -r requirements.txt

COPY . /srv/everware
RUN pip install -e . && \
    python setup.py css && \
    python setup.py js

EXPOSE 8000
EXPOSE 8081

ENTRYPOINT ["/tini", "--", "/srv/everware/scripts/everware-server", "-f"]
