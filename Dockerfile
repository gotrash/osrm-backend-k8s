FROM python:3

LABEL \
  maintainer="Alex Scott <codetheorist@outlook.com>" \
  org.opencontainers.image.title="osrm-backend-k8s" \
  org.opencontainers.image.description="Open Source Routing Machine (OSRM) osrm-backend for Kubernetes." \
  org.opencontainers.image.authors="Alex Scott <codetheorist@outlook.com>" \
  org.opencontainers.image.url="https://github.com/gotrash/osrm-backend-k8s" \
  org.opencontainers.image.vendor="https://github.com/gotrash" \
  org.opencontainers.image.licenses="MIT"

ENV OSRM_VERSION 5.27.1

# Let the container know that there is no TTY
ARG DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get -y update \
  && apt-get install -y -qq \
    build-essential \
    cmake \
    curl \
    libbz2-dev \
    libstxxl-dev \
    libstxxl1v5 \
    libxml2-dev \
    libzip-dev \
    libboost-all-dev \
    lua5.2 \
    liblua5.2-dev \
    libtbb-dev \
    libluabind-dev \
    pkg-config \
    gcc \
    python-dev \
    python-setuptools \    
 && apt-get clean \
 && easy_install -U pip \
 && pip install -U crcmod \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/*

# Build osrm-backend
RUN mkdir /osrm-src \
 && cd /osrm-src \
 && curl --silent -L https://github.com/Project-OSRM/osrm-backend/archive/v$OSRM_VERSION.tar.gz -o v$OSRM_VERSION.tar.gz \
 && tar xzf v$OSRM_VERSION.tar.gz \
 && cd osrm-backend-$OSRM_VERSION \
 && mkdir build \
 && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
 && cmake --build . \
 && cmake --build . --target install \
 && mkdir /osrm-data \
 && mkdir /osrm-profiles \
 && cp -r /osrm-src/osrm-backend-$OSRM_VERSION/profiles/* /osrm-profiles \
 && rm -rf /osrm-src

# Set the entrypoint
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5000
