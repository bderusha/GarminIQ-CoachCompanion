FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG CONNECTIQ_SDK_VERSION=9.2.0

ENV CONNECTIQ_HOME=/opt/garmin/connectiq-sdk \
    CONNECTIQ_SDK_HOME=/opt/garmin/connectiq-sdk \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    PATH=/opt/garmin/connectiq-sdk/bin:${PATH}

RUN if [ "$(dpkg --print-architecture)" != "amd64" ]; then \
        echo "The Garmin Connect IQ Linux SDK supports only x86_64/amd64 containers." >&2; \
        exit 1; \
    fi \
    && apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        libgtk-3-0 \
        libsecret-1-0 \
        libusb-1.0-0 \
        libwebkit2gtk-4.0-37 \
        openjdk-17-jdk-headless \
        openssl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN sdk_file="$(curl -fsSL --retry 3 \
        https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json \
        | jq -er --arg version "${CONNECTIQ_SDK_VERSION}" \
            '.[] | select(.version == $version) | .linux')" \
    && mkdir -p "${CONNECTIQ_SDK_HOME}" \
    && curl -fsSL --retry 3 \
        "https://developer.garmin.com/downloads/connect-iq/sdks/${sdk_file}" \
        -o /tmp/connectiq-sdk.zip \
    && unzip -q /tmp/connectiq-sdk.zip -d "${CONNECTIQ_SDK_HOME}" \
    && chmod +x "${CONNECTIQ_SDK_HOME}"/bin/* \
    && rm /tmp/connectiq-sdk.zip \
    && test "$(cat "${CONNECTIQ_SDK_HOME}/bin/version.txt")" = "${CONNECTIQ_SDK_VERSION}"

RUN mkdir -p /opt/garmin/sdk-manager \
    && curl -fsSL --retry 3 \
        https://developer.garmin.com/downloads/connect-iq/sdk-manager/connectiq-sdk-manager-linux.zip \
        -o /tmp/connectiq-sdk-manager.zip \
    && unzip -q /tmp/connectiq-sdk-manager.zip -d /opt/garmin/sdk-manager \
    && chmod +x /opt/garmin/sdk-manager/bin/sdkmanager \
    && ln -s /opt/garmin/sdk-manager/bin/sdkmanager /usr/local/bin/sdkmanager \
    && rm /tmp/connectiq-sdk-manager.zip

COPY setup-user.sh /usr/local/share/connectiq/setup-user.sh
RUN chmod +x /usr/local/share/connectiq/setup-user.sh