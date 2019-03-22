# learning-jenkins

# Semi-Automated Setup

TODO: bash script to set all this up, since bash will be installed by default on a CentOS 7 test host

## Install `inspec`, `docker`, and `ansible`

    # yum install inspec docker python-docker-py ansible

## Run the Ansible do-most-everything playbook as `jenkins`

    # su - jenkins
    $ git clone https://github.com/sbonds/learning-jenkins.git
    $ cd learning-jenkins/ansible
    $ ansible-playbook --inventory=localhost, setup-jenkins-docker.yaml
    (complete the Web based setup wizard by hand.)
    $ ansible-playbook --vault-password-file secret_vault_password --inventory=localhost, setup-jenkins-docker-2.yaml

(The extra comma after `localhost,` is important to distinguish a list of one host from a filename.)

## Run the inspec check as `jenkins`

    $ cd inspec
    $ vi rhel7_docker/attributes.yml
    local_subnet: <the source address in your firewall rule for 8080/50000 below>
    $ inspec exec rhel7_docker --attrs=rhel7_docker/attributes.yml

# Host Setup

## Inspec

Used to check whether everything is set up on the host to a point where Ansible can work.

## Docker

Docker was installed on a CentOS 7 server.

## Ansible

This will be used to automate changes needed to the host and/or Docker containers.

## Java or OpenJDK

Used for the Jenkins CLI

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

TODO: Due to a bug in `polkit` no non-root reading of firewall rules works right now. Details at:
* https://github.com/firewalld/firewalld/issues/111
* https://bugzilla.redhat.com/show_bug.cgi?id=1375655

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

## Ansible playbook for starting Jenkins

Interestingly, the Ansible folks even use Jenkins-in-Docker as one of their examples:

https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#non-ssh-connection-types

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

Download it from the Jenkins Docker image at `http://localhost:8080/jnlpJars/jenkins-cli.jar`

## Initial Admin Password

http://www.scmgalaxy.com/tutorials/complete-guide-to-use-jenkins-cli-command-line/

### Login to Jenkins using initialAdminPassword 

Use the user `admin` and the password from `/var/jenkins_home/secrets/initialAdminPassword`:

    $ java -jar jenkins-cli.jar -s http://localhost:8080 who-am-i --username admin --password <initial password>
    Authenticated as: admin
    Authorities:
      authenticated

From here we can create an additional user, but that should be parameterized.

## Complete Jenkins setup wizard

TODO: Set up Ansible parameters (vault?) for the instance-specific details

Setting up Jenkins ends up being very difficult from Ansible since it's not something the Jenkins CLI can do.

https://github.com/solita/ansible-role-solita.jenkins
https://github.com/geerlingguy/ansible-role-jenkins/issues/50

Or perhaps just use his Ansible role as-is?

https://github.com/geerlingguy/ansible-role-jenkins

Perhaps grab a CentOS Docker image and install within there to maintain the benefits of a container AND use a pre-made Ansible role instead continuing down my path of wheel re-invention? (That turned into a nasty episode of [Yak Shaving](http://www.catb.org/~esr/jargon/html/Y/yak-shaving.html). Rather than waste more time before I can get to the real learning, move on to learn more about the Jenkins CLI by simply completing the Setup Wizard by hand.)

TODO: Automate the Setup Wizard process of Jenkins.

### Option 1: Ansible URL methods

This means decoding each conversation with Jenkins and submitting the same data via HTTP POST forms. Ugly and brittle!

### Option 2: Disable the Setup Wizard

This also disables security and leaves us with an unconfigured Jenkins. Those might be things we can correct with automation, though.

It's unclear how to disable the Wizard once Jenkins is already installed. Normally this is done via a Java parameter passed to the Jenkins WAR file.

### Option 3: Selenium browser automation to complete wizard

Sometimes when something needs to move, pushing harder is the answer. This will further complicate out host system setup.

## GitHub access

Jenkins needs the above GitHub API key. This should be considered sensitive information so should not be stored in GitHub. However unless you want to type it in every time, it'll need to be stored somewhere.

It went into the `ansible/jenkins-private-info.yaml` Ansible Vault file.

## Jenkins Job

The CLI manages jobs via raw XML files.

https://stackoverflow.com/questions/8424228/export-import-jobs-in-jenkins

It does not appear to be possible to define a new job using the CLI except by XML import. Note that the XML would be exceedingly difficult to craft by hand, if not outright impossible, due to its dependencies on specific internally referenced ID numbers.

It would be interesting to see how well an export from one environment (e.g. sandbox) and and import into a new environment (e.g. staging) using the job export/import would work out.

# Check build log

Good news:

    + go version
    go version go1.12.1 linux/amd64

# Bare metal physical server setup

There's nothing like starting from (almost) nothing to ensure that a process works. What is needed to set up a Docker host starting from an empty server?

## Hardware config

While other hardware would likely work, this is what I have available. These 5+ year old servers can be found very cheap and are new enough that power usage was starting to be a concern, so they only pull about 100W instead of the 300W of older models. It adds up when running 24x7.

### Server: HP DL380 G7

## Boot config

Goal: Boot the server for PXE network boot and the OS gets installed

### DHCP

TODO: Inspec test for DHCP entries

### DDNS (optional)

TODO: Is there a way for the ILO to register its connection into a DNS subdomain?

### PXE/TFTP

TODO: Inspec test for PXE entries and related configs needed to network boot

### iSCSI (optional)

TODO: Avoid the need for internal drives and boot from iSCSI. This never worked well and internal drives in the server are not hard to arrange, so this is a pretty low priority

### Kickstart

Defines the OS configuration as much as possible. Avoid complex Bash scripts in favor of Ansible later.

### Ansible

Configure things that can't be easily captured in Kickstart.

# Why all this?

## Explore Jenkins Setup

I thought this would be a quick and easy thing to try out, after all, Jenkins had a well-made Docker container available and the "Hello, world" nature of the exercise seems very simple.

I was wrong.

Just getting a Docker host set up ended up being a bit of an adventure, and it's not documented here because much of it was probably self-inflicted from trying to use one OS image for too many things. However, since I don't have the money to pay for an electricity bill any larger than it already is, I try to do as much as possible on one server.

Once I get this process working reasonably well, I can try it from the very beginning on a freshly installed CentOS 7 server. That will help me (re) document any issues from the initial Docker setup.

## Docker images side by side

Getting one Docker container to tell the host how to create other Docker containers should have been pretty simple. The problem is the volume mapping makes no allowance for a GID mismatch between the container host and the containers themselves. Since I can't confirm that every possible container will agree on a GID for the "docker" user (and the owner of the docker IPC socket) it quickly became clear that I'd be reconfiguring a lot of containers.

Any time I need to do something a lot, I think of automation. And Ansible works nicely for automation.

## Inspec

Since I'm trying to encourage myself to use Behavior Driven Infrastructure Development, this was a good place to start. Define what I think the host should look like and then write some tests to confirm it. We'll see how well this helps when I get to the aforementioned "set it all up again starting from nothing" phase. For now, this was mostly just a chance to learn Inspec a bit better by having a project that required it.
