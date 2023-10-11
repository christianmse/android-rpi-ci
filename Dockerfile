FROM jenkins/jenkins:jdk21
USER root
WORKDIR /
SHELL ["/bin/bash", "-c"]

ARG ANDROID_BUILD_TOOLS=10406996_latest
ARG ANDROID_BUILD_TOOLS_LEVEL=34.0.0
ARG ANDROID_API_LEVEL=34
ARG GRADLE_VERSION=8.2
ARG ANDROID_SDK_ROOT=/opt/android

# Dependencies and needed tools
RUN apt update -qq && \
    apt install -qq -y git unzip libglu1 libpulse-dev libasound2 libc6 \
    libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
    libxi6  libxtst6 libnss3 wget

# Download Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
    && unzip -q -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip

# Download Android command line tools
RUN export ANDROID_SDK_ROOT="/opt/android/"
RUN mkdir $ANDROID_SDK_ROOT

RUN wget -q --output-document=$ANDROID_SDK_ROOT/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_BUILD_TOOLS}.zip
WORKDIR $ANDROID_SDK_ROOT
RUN unzip cmdline-tools.zip -d cmdline-tools && rm -rf cmdline-tools.zip
# Move into the comdline-tool
WORKDIR cmdline-tools

# Inside the cmdline-tools directory there is another directory named cmdline-tool, rename it to tools
RUN mv cmdline-tools tools || true

RUN echo $(ls -l $ANDROID_SDK_ROOT)
ENV GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
ENV PATH "$PATH:$GRADLE_HOME/bin:$ANDROID_HOME/cmdline-tools/tools/bin"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"

# Checking if export of the path works by checking the SDK version
RUN sdkmanager --version

# Use yes to accept licenses
RUN yes | sdkmanager --licenses || true

# Clean up
RUN rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

# Set Volome to SDK location
VOLUME $ANDROID_SDK_ROOT
VOLUME $JENKINS_HOME

USER jenkins
WORKDIR /
