FROM balenalib/raspberrypi4-64-debian-openjdk:11-bullseye

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_USER admin
ENV JENKINS_PASS pass

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && apt install -y python3 python3-pip \
  && pip3 install ansible \
  && pip3 install openshift
  
RUN echo "export PATH=$PATH:~/.local/bin" >> ~/.bashrc && . ~/.bashrc

# download the 2.340 version of jenkinsci
RUN curl -fL -o /opt/jenkins.war https://updates.jenkins-ci.org/download/war/2.340/jenkins.war 

# download install-plugins
RUN curl --http1.1 https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh -output $JENKINS_HOME/

VOLUME ${JENKINS_HOME}
WORKDIR ${JENKINS_HOME}

# install plugins
RUN while read i; \
	do install-plugins.sh $i ; \
	done < ./plugins

EXPOSE 8080 ${JENKINS_SLAVE_AGENT_PORT}

CMD ["/bin/bash","-c","java -jar /opt/jenkins.war"]
