FROM debian:stretch

RUN apt-get update && \ 
    apt-get install -yq software-properties-common java-common openjdk-11 android-sdk-platform-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://github.com/MarathonLabs/marathon/releases/
RUN cd /usr/local && wget https://github.com/Malinskiy/marathon/releases/download/0.8.1/marathon-0.8.1.zip && \
    unzip marathon-0.8.1.zip && \
    mv marathon-0.8.1 marathon && \
    rm marathon-0.8.1.zip
ENV PATH=$PATH:/usr/local/marathon/bin
ENV ANDROID_HOME=/usr/lib/android-sdk
WORKDIR /work
CMD ["/usr/local/marathon/bin/marathon"]
