FROM centos:centos8

ENV LANG=C.UTF-8
ENV OSSUTIL_VERSION=1.7.7

# timezone
ENV TZ Asia/Shanghai

LABEL org.label-schema.vendor="potato<silenceace@gmail.com>" \
    org.label-schema.name="java-node-python-go-etc" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.description="Java8 mvn3.3.9 Go1.16.7 python3.6.8 node10.24.0 npm8.1.4 yarn1.22.17 nginx1.14 openssh zip tar wget rsync git bash webhook" \
    org.label-schema.url="https://yycc.me" \
    org.label-schema.schema-version="1.0"	\
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/funnyzak/java-node-python-go-etc" 

# base soft
RUN yum update -y
RUN yum install -y openssl* && \
    yum install -y bash git openssh go rsync nodejs golang python3 && \
    yum install -y curl nginx zip unzip gzip bzip2 tar wget tzdata

# npm china mirrors
RUN true \
    && npm config set registry https://registry.npm.taobao.org \
    && npm config set disturl https://npm.taobao.org/dist \
    && npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass \
    && npm config set electron_mirror https://npm.taobao.org/mirrors/electron \
    && npm config set puppeteer_download_host https://npm.taobao.org/mirrors \
    && npm config set chromedriver_cdnurl https://npm.taobao.org/mirrors/chromedriver \
    && npm config set operadriver_cdnurl https://npm.taobao.org/mirrors/operadriver \
    && npm config set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs \
    && npm config set selenium_cdnurl https://npm.taobao.org/mirrors/selenium

# n yarn
RUN npm install -g n yarn

# ossutil64
RUN mkdir -p /mnt/app
RUN curl -Lo /mnt/app/ossutil64 http://gosspublic.alicdn.com/ossutil/${OSSUTIL_VERSION}/ossutil64          
RUN chmod 755 /mnt/app/ossutil64
RUN ln -s /mnt/app/ossutil64 /usr/local/bin

# Install Go Webhook
RUN go get github.com/adnanh/webhook

# download maven 3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-3.3.9.tar.gz http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
# install maven
RUN tar xzf /tmp/apache-maven-3.3.9.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.3.9 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.3.9.tar.gz
ENV MAVEN_HOME /opt/maven

# set shell variables for java installation
ENV java_version jdk8u282-b08
ENV filename OpenJDK8U-jdk_x64_linux_hotspot_8u282b08.tar.gz
ENV downloadlink https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/$java_version/$filename
# download java
RUN wget --no-cookies -O /tmp/$filename $downloadlink 
# java env
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
RUN rm -f /tmp/$filename
ENV JAVA_HOME /opt/java-oracle/$java_version
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/jre/lib/rt.jar:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH ${JAVA_HOME}/bin:$PATH


RUN mkdir /workspace
RUN chmod -R 777 /workspace
WORKDIR /workspace
VOLUME /workspace

COPY ./cmd.sh /

EXPOSE 80

CMD ["/bin/bash", "/cmd.sh"]
