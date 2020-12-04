FROM node:10.6.0

LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.created="2020/05/19"
LABEL org.opencontainers.image.authors="Jesus Moreno Amor <jesus@morenoamor.com>"
LABEL org.opencontainers.image.ref.name="ionic-builder-3"
LABEL org.opencontainers.image.title="Ionic 3 builder image"
LABEL org.opencontainers.image.description="Ionic 3 builder image"

# ##################################################################################################
# Environment
# ##################################################################################################
ENV GRADLE_HOME /usr/local/gradle
ENV GRADLE_VERSION 6.0.1

ENV CORDOVA_VERSION 10.0.0
ENV IONIC_VERSION 3.20.0

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_TOOLS_VERSION r25.2.5
ENV ANDROID_API_LEVELS android-29
ENV ANDROID_BUILD_TOOLS_VERSION 29.0.2

ENV PATH ${GRADLE_HOME}/bin:${JAVA_HOME}/bin:${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

# ##################################################################################################
# Base packages
# ##################################################################################################
RUN apt-get update && apt-get install -y --no-install-recommends curl software-properties-common \
    unzip rsync make

# ##################################################################################################
# Install Java
# ##################################################################################################
RUN echo "deb http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y --no-install-recommends -t jessie-backports openjdk-8-jdk

# ##################################################################################################
# Install Graddle
# ##################################################################################################
RUN mkdir -p ${GRADLE_HOME} && \
  curl -L https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip > /tmp/gradle.zip && \
  unzip /tmp/gradle.zip -d ${GRADLE_HOME} && \
  mv ${GRADLE_HOME}/gradle-${GRADLE_VERSION}/* ${GRADLE_HOME} && \
  rm -r ${GRADLE_HOME}/gradle-${GRADLE_VERSION}/ && \
  rm -rf /tmp/*

# ##################################################################################################
# Install Android
# ##################################################################################################
RUN mkdir -p ${ANDROID_HOME} && \
  curl -L https://dl.google.com/android/repository/tools_${ANDROID_TOOLS_VERSION}-linux.zip > /tmp/tools.zip && \
  unzip /tmp/tools.zip -d ${ANDROID_HOME} && \
# Android SDK
  echo y | android update sdk --no-ui -a --filter platform-tools,${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
# Make license agreement
  mkdir $ANDROID_HOME/licenses && \
  echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license && \
  echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license && \
  echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> $ANDROID_HOME/licenses/android-sdk-license && \
  echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license && \
  rm -rf /tmp/*

# ##################################################################################################
# Install Ionic and Cordova
# ##################################################################################################
RUN npm install -g cordova@${CORDOVA_VERSION} ionic@${IONIC_VERSION}
