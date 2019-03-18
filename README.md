# learning-jenkins
Learn how to get Jenkins CI/CD working

# Docker Setup

Docker was installed on a CentOS 7 server.

# GitHub Setup

## API Key creation for Jenkins to use

Create an API key with `repo`, `read:org`, `admin:repo_hook`, and `user:email` roles.

## Create repo for Jenkins learning

## Install Jenkinsfile into the root of the above Github Repo

For example, one of the simple examples from https://jenkins.io/doc/pipeline/tour/hello-world/

# Start Jenkins via Docker

## Check the GID of the `docker` group

    # grep docker /etc/group

Note the GID for later.

## Set up `jenkins` user to run docker commands

Make sure the host user `jenkins` can run docker commands:

    # useradd --groups docker jenkins

## Open up local firewall

Make sure external hosts can reach Jenkins on this host (assumes firewall is running). Replace 10.1.2.0/24 with an appropriate host scope that will need to reach Jenkins:

    # firewall-cmd --permanent --zone=public --add-rich-rule='
      rule family="ipv4"
      source address="10.1.2.0/24"
      port protocol="tcp" port="8080" accept'
    # firewall-cmd --permanent --zone=public --add-rich-rule='
      rule family="ipv4"
      source address="10.1.2.0/24"
      port protocol="tcp" port="50000" accept'
    # firewall-cmd --reload
    # firewall-cmd --list-rich-rules

## Create Jenkins docker image

Grab the Jenkins Docker image and fire it up. Map /var/run/docker.sock so that this Docker image can access docker to create other Docker instances in parallel to itself on the host server.

    $ docker run --name jenkins --detach --publish 8080:8080 -p 50000:50000 --volume jenkins-data:/home/jenkins/jenkins_home --volume /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean

## Fix GID mismatch in Docker group and add `jenkins`

    $ docker exec -it -u root jenkins bash
    # vi /etc/group
    docker:x:101:jenkins
    (Replace 101 with the GID of `docker` on the host server)
    # exit
    $ docker restart jenkins

# Configure Jenkins

TODO

# Check build log

Good news:

    + go version
    go version go1.12.1 linux/amd64

