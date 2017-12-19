# docker-jenkins

Jenkins docker image, based off [OpenJDK](http://openjdk.java.net/) 8 on [Alpine Linux](https://alpinelinux.org/), with additional plugins

This is available on Docker hub as [garethjevans/jenkins](https://hub.docker.com/r/garethjevans/jenkins/)

## Usage

To create a basic Jenkins Master instance use:

```
docker run \
    --detach \
    --env LANG=C.UTF-8 \
    --name jenkins \
    --publish 80:8080 \
    --publish 50000:50000 \
    --volume `pwd`/example.init.d/:/var/jenkins_home/init.groovy.d \
    --volume /etc/localtime:/etc/localtime:ro \
    garethjevans/jenkins:latest
```
