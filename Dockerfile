FROM jenkins

# Install plugins
COPY plugins.txt /usr/local/etc/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/local/etc/plugins.txt

# set shell variables for java installation
ENV java_version 1.7.0_72
ENV filename  jdk-7u72-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/7u72-b14/$filename

USER root

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink && \
	tar -zxf /tmp/$filename -C /opt/ && \
	update-alternatives --install /usr/bin/java java /opt/jdk$java_version/bin/java 2 && update-alternatives --install /usr/bin/javac javac /opt/jdk$java_version/bin/javac 2

ENV MAVEN_VERSION 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-${MAVEN_VERSION}.tar.gz http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
	tar xzf /tmp/apache-maven-${MAVEN_VERSION}.tar.gz -C /opt/ && \
	ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
	ln -s /opt/maven/bin/mvn /usr/local/bin && \
	rm -f /tmp/apache-maven-${MAVEN_VERSION}.tar.gz

ENV MAVEN_HOME /opt/maven

USER jenkins
