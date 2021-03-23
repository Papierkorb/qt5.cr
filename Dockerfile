FROM crystallang/crystal:0.36.1

RUN apt-get update && apt-get install \
  qtbase5-dev \
  cmake \
  wget \
  lsb-release \
  software-properties-common \
  clang-11 \
  libclang-11-dev \
  zlib1g-dev \
  libncurses-dev \
  libgc-dev \
  libpcre3-dev

WORKDIR /tmp

RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 11
RUN ln -s /usr/bin/llvm-config-11 /usr/bin/llvm-config