# https://mcr.microsoft.com/v2/devcontainers/cpp/tags/list
# https://github.com/devcontainers/images/tree/main/src/cpp/history
ARG GET_ALL_NON_BREAKING_CHANGES=1
ARG ONLY_GET_FIXES=1.2
FROM mcr.microsoft.com/devcontainers/cpp:${GET_ALL_NON_BREAKING_CHANGES}-ubuntu-24.04

# https://cmake.org/download/
ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="4.2.3"

# Optionally install the cmake for vcpkg
COPY ./reinstall-cmake.sh /tmp/

RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
        chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
    fi \
    && rm -f /tmp/reinstall-cmake.sh

# [Optional] Uncomment this section to install additional vcpkg ports.
# RUN su vscode -c "${VCPKG_ROOT}/vcpkg install <your-port-name-here>"

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>




# dev
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        gcc-14 g++-14 \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 1 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 1

# admin tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        ascii \
        bat \
        feh \
        file \
        fish \
        hwinfo \
        lsd \
        mc \
        rename \
        scrot \
        tree \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# dev tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        autoconf \
        autoconf-archive \
        automake \
        bison \
        cmake-format \
        dialog \
        dos2unix \
        doxygen \
        expect \
        flex \
        graphviz \
        libtool \
        mkdocs \
        netpbm \
        shellcheck \
        wmctrl \
        xa65 \
        xxd \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# audio
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        alsa-base \
        alsa-utils \
        beep \
        libsndfile1-dev \
        pulseaudio \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# dev deps
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        libgl1-mesa-dev \
        libglu1-mesa-dev \
        libltdl-dev \
        libx11-dev \
        libxcursor-dev \
        libxft-dev \
        python3-jinja2 \
        python3-pip \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# zig deps
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        # libjpeg-dev libpng-dev libgif-dev \
        # libtiff-dev libwebp-dev libfreetype-dev libfontconfig-dev \
        # libx11-dev libxfixes-dev libxext-dev libxrandr-dev \
        # libwayland-dev libxkbcommon-dev swig python3-dev \
        libsdl2-dev  \
        # libsdl1.2-dev libsdl-image1.2-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# deps
# RUN <<EOF
# EOF

# zig

ARG VSCODE_HOME=/home/vscode
ARG ZIG_ARCHIVE_VERSION=0.16.0-dev.2535+b5bd49460
ARG ZIG_ARCHIVE_STEM=zig-aarch64-linux-${ZIG_ARCHIVE_VERSION}
ARG ZIG_ARCHIVE=${ZIG_ARCHIVE_STEM}.tar.xz
ENV ZIG_ROOT=${VSCODE_HOME}/zig
RUN <<EOF
cd ${VSCODE_HOME}
curl -O https://ziglang.org/builds/${ZIG_ARCHIVE}
tar -xJf ${ZIG_ARCHIVE}
mv ${ZIG_ARCHIVE_STEM} zig
rm ${ZIG_ARCHIVE}
chown -R vscode:vscode zig
EOF

# starship

RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y

# zsh config

RUN <<EOF
{
    echo 'eval "$(starship init zsh)"';
    echo 'alias ls="lsd"';
    echo 'alias cat="batcat"';
    echo 'export PATH=$ZIG_ROOT:$PATH';
} >> ${VSCODE_HOME}/.zshrc
EOF

ARG GITHUB_BRANCH_NAME="zig"
ENV WORKSPACE_ROOT=/workspaces/${GITHUB_BRANCH_NAME}
ENV DEV_ROOT=${WORKSPACE_ROOT}/dev