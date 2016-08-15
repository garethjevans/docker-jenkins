FROM java:8-jdk

RUN apt-get update && apt-get install -y wget git curl zip graphviz && rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/volume from a data container, 
# ensure you use same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

# Jenkins home directoy is a volume, so configuration and build history 
# can be persisted and survive image upgrades
# VOLUME /var/jenkins_home

# `/usr/share/jenkins/ref/` contains all reference configuration we want 
# to set on a fresh new installation. Use it to bundle additional plugins 
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

ENV TINI_VERSION 0.9.0
ENV TINI_SHA fa23d1e20732501c3bb8eeeca423c89ac80ed452

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA /bin/tini" | sha1sum -c -

# COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

ENV JENKINS_VERSION 2.7.2
ENV JENKINS_SHA 4c05175677825a0c311ef3001bbb0a767dad0e8d

# could use ADD but this one does not check Last-Modified header 
# see https://github.com/docker/docker/issues/8331
RUN curl -fL http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war \
  -o /usr/share/jenkins/jenkins.war \
  && echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -

ENV JENKINS_UC https://updates.jenkins-ci.org
RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY plugins.sh /usr/local/bin/plugins.sh

RUN chown jenkins:jenkins /usr/local/bin/jenkins.sh && \
	chown jenkins:jenkins /usr/local/bin/plugins.sh && \
	chmod a+x /usr/local/bin/jenkins.sh && \
	chmod a+x /usr/local/bin/plugins.sh

ENV SONAR_VERSION 2.4
RUN wget --quiet http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/${SONAR_VERSION}/sonar-runner-dist-${SONAR_VERSION}.zip && \
	unzip sonar-runner-dist-${SONAR_VERSION}.zip && \
	mv sonar-runner-${SONAR_VERSION} /opt/sonar-runner && \
	chown -R jenkins:jenkins /opt/sonar-runner

ENV NEWRELIC_AGENT_VERSION 3.28.0
RUN wget --quiet https://download.run.pivotal.io/new-relic/new-relic-${NEWRELIC_AGENT_VERSION}.jar && \
	mkdir /opt/newrelic && \
	mv new-relic-${NEWRELIC_AGENT_VERSION}.jar /opt/newrelic/new-relic.jar && \
	chown -R jenkins:jenkins /opt/newrelic

COPY newrelic.yml /opt/newrelic/

USER jenkins

# Install plugins
COPY plugins.txt /usr/local/etc/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/local/etc/plugins.txt #redo

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
