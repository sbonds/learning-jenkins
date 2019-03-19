# learning-jenkins
Learn how to get Jenkins CI/CD working

# Host Setup

## Inspec

Used to check whether everything is set up on the host to a point where Ansible can work.

## Docker

Docker was installed on a CentOS 7 server.

## Ansible

This will be used to automate changes needed to the host and/or Docker containers.

## Java or OpenJDK

Used for the Jenkins CLI

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

# Configure Jenkins inside container

## Jenkins CLI

Download it from the Jenkins Docker image at `https://localhost:8080/jnlpJars/jenkins-cli.jar`

## Initial Admin Password

http://www.scmgalaxy.com/tutorials/complete-guide-to-use-jenkins-cli-command-line/

Login Jenkins using initialAdminPassword try user `admin` and password from `Jenkins\secrets\initialAdminPassword`

    $ java -jar jenkins-cli.jar -s http://localhost:8080 who-am-i –username admin –password <initial password>

## GitHub access

Jenkins needs the above GitHub API key. This should be considered sensitive information so should not be stored in GitHub. However unless you want to type it in every time, it'll need to be stored somewhere.

Ansible vault, perhaps? (Since I plan to use Ansible anyhow for the host config info.)

# Check build log

Good news:

    + go version
    go version go1.12.1 linux/amd64

