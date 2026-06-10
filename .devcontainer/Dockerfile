FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator:${PATH}"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Dependências base
RUN apt-get update && apt-get install -y \
    curl git unzip wget xz-utils zip \
    openjdk-17-jdk \
    libglu1-mesa libpulse0 libgl1 libgl1-mesa-dri libegl1 \
    usbutils udev \
    nodejs npm \
    clang cmake ninja-build pkg-config libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK (stable)
RUN git clone --depth 1 --branch stable \
    https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter precache --android

# Android command-line tools
# Verifique a versão mais recente em: https://developer.android.com/studio\#command-line-tools-only
ARG CMDTOOLS_BUILD=11479570
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${CMDTOOLS_BUILD}_latest.zip" \
      -O /tmp/cmdtools.zip && \
    unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools && \
    mv /tmp/cmdtools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm -rf /tmp/cmdtools /tmp/cmdtools.zip

# Aceitar licenças e instalar SDK
RUN yes | sdkmanager --licenses && \
    sdkmanager \
      "platform-tools" \
      "platforms;android-36" \
      "build-tools;36.0.0" \
      "emulator" \
      "system-images;android-36;google_apis;x86_64"

# Criar AVD para emulador headless
RUN echo "no" | avdmanager create avd \
    -n gema_emulator \
    -k "system-images;android-36;google_apis;x86_64" \
    --device pixel_6 \
    --force

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Criar usuário não-root (boa prática)
ARG USER_UID=1000
ARG USER_GID=1000
RUN userdel -r ubuntu 2>/dev/null || true; \
    groupdel ubuntu 2>/dev/null || true; \
    if getent group ${USER_GID} > /dev/null 2>&1; then groupmod -n dev $(getent group ${USER_GID} | cut -d: -f1); else groupadd -g ${USER_GID} dev; fi && \
    if getent passwd ${USER_UID} > /dev/null 2>&1; then usermod -l dev -d /home/dev -m $(getent passwd ${USER_UID} | cut -d: -f1); else useradd -u ${USER_UID} -g ${USER_GID} -ms /bin/bash dev; fi && \
    chown -R dev:dev ${FLUTTER_HOME} ${ANDROID_HOME}

USER dev
WORKDIR /workspace

RUN yes | sdkmanager --licenses && \
    sdkmanager \
      "platform-tools" \
      "platforms;android-36" \
      "build-tools;36.0.0" \
      "emulator" \
      "system-images;android-36;google_apis;x86_64"
RUN yes | flutter doctor --android-licenses 2>/dev/null || true
# Verificação final
RUN flutter doctor --android-licenses 2>/dev/null; flutter doctor
