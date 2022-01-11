FROM ubuntu:focal

RUN apt-get update -y \
      && apt-get install -y --no-install-recommends git-core \
                                                    openssl \
                                                    make \
                                                    libc6-dev \
                                                    build-essential \
                                                    pcre2-utils libpcre3 libpcre3-dev \
                                                    unzip \
                                                    wget libcurl4 curl\
      && rm -rf /var/lib/apt/lists/*

# !!! This is dangerous !!! kong.git requires SSL certificate
RUN git config --global http.sslverify false

# Setup file structure
ENV BUILD_DIR=kong_runtime \
    CACHE_DIR=kong_cache \
    ENV_DIR=kong_env_dir \
    BP_DIR=kong_bp_dir

RUN mkdir -p /app

WORKDIR /app

RUN mkdir -p ${BP_DIR} ${BUILD_DIR} ${CACHE_DIR} ${ENV_DIR}

COPY . /app

RUN ./bin/compile1 /${BP_DIR} /${BUILD_DIR} /$CACHE_DIR /${ENV_DIR}

CMD ./bin/compile2 /${BP_DIR} /${BUILD_DIR} /$CACHE_DIR /${ENV_DIR}

