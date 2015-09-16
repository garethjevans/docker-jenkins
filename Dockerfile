FROM jenkins

# Install plugins
COPY plugins.txt /usr/local/etc/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/local/etc/plugins.txt

RUN /usr/local/bin/plugins.sh /usr/local/etc/plugins.txt
COPY init/* 'pwd'/jobs:/var/jenkins_home/init.groovy.d/

# set shell variables for java installation
ENV java_version 1.7.0_72
ENV filename  jdk-7u72-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/7u72-b14/$filename

USER root

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink

# unpack java
RUN tar -zxf /tmp/$filename -C /opt/

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java /opt/jdk$java_version/bin/java 2 && update-alternatives --install /usr/bin/javac javac /opt/jdk$java_version/bin/javac 2

# get maven 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz

# install maven
RUN tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.2.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.2.2.tar.gz
ENV MAVEN_HOME /opt/maven
