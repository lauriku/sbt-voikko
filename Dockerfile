FROM openjdk:8
MAINTAINER Lauri Kuittinen <lauri.kuittinen@gofore.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      libmalaga-dev \
      execstack \
    && rm -rf /var/lib/apt/lists/*

ENV VOIKKO_PREFIX /usr/local/voikko
ENV VOIKKO_VERSION 3.7.1
    
RUN mkdir -p /tmp/voikko && \
    cd /tmp/voikko && \
    curl -sL "http://www.puimula.org/voikko-sources/libvoikko/libvoikko-${VOIKKO_VERSION}.tar.gz" \
    | gunzip | tar -x -C /tmp/voikko && \
    cd libvoikko-${VOIKKO_VERSION} && \
    ./configure --prefix ${VOIKKO_PREFIX} --with-dictionary-path=${VOIKKO_DICTS} && \
    make \
    && make install

RUN rm -rf /tmp/voikko

RUN execstack -c ${VOIKKO_PREFIX}/lib/libvoikko.so
RUN ln -sv ${VOIKKO_PREFIX}/lib/libvoikko.so /usr/lib/libvoikko.so
RUN ldconfig

ENV SBT_VERSION 0.13.11
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

# Install sbt
RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

WORKDIR /app
