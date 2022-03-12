FROM python:3.8

RUN set -ex && \
    sed -i 's/http:\/\/deb.\(.*\)/https:\/\/deb.\1/g' /etc/apt/sources.list && \
    apt-get update && \
    ln -s /lib /lib64 && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt install -y -qq bash tini libc6 libpam-modules krb5-user libnss3 openjdk-11-jre && \
    apt install -y -qq wget unzip curl vim git && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

ARG spark_version="3.0.3"
ARG hadoop_version="3.2"
ENV APACHE_SPARK_VERSION="${spark_version}" \
    HADOOP_VERSION="${hadoop_version}"
ENV SPARK_HOME /opt/spark
ENV JAVA_HOME /usr
RUN wget -q "https://dlcdn.apache.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" && \
    tar xzf "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /opt && \
    mv "/opt/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" ${SPARK_HOME} && \
    rm "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

RUN cd /opt/spark/python && pip3 install -e .

RUN wget -q "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.874/aws-java-sdk-1.11.874.jar"
RUN wget -q "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.874/aws-java-sdk-bundle-1.11.874.jar"
RUN wget -q "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar"
RUN wget -q "https://github.com/jpmml/jpmml-sparkml/releases/download/1.6.6/jpmml-sparkml-executable-1.6.6.jar"
RUN cp *.jar /opt/spark/jars/

WORKDIR /opt/spark/
RUN chmod g+w /opt/spark/
COPY entrypoint.sh /opt/
ENTRYPOINT [ "/opt/entrypoint.sh" ]
