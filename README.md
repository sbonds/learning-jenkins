# learning-jenkins

# Semi-Automated Setup

TODO: bash script to set all this up, since bash will be installed by default on a CentOS 7 test host

## Install `inspec`, `docker`, and `ansible`

    # yum install inspec docker python-docker-py ansible

## Run the "red" inspec check as `jenkins`

For the "red" test we expect some of these to fail, depending on how much was already set up.

    $ cd inspec
    $ inspec exec rhel7_docker

## Run the Ansible do-some-simple-things playbook as `jenkins`

    # su - jenkins
    $ git clone https://github.com/sbonds/learning-jenkins.git
    $ cd learning-jenkins/ansible
    $ ansible-playbook --inventory=localhost, setup-jenkins-docker.yaml
    (complete the Web based setup wizard by hand using the initial admin password printed by Ansible)

(The extra comma after `localhost,` is important to distinguish a list of one host from a filename.)

## Run the "green" inspec check as `jenkins`

    $ cd inspec
    $ inspec exec rhel7_docker

## Configure a Jenkins pipeline for this project

### Connect to Jenkins

It will be on your Docker host on port 8080 via HTTP.

### Enter the Administrator password

Ansible should have shown it to you late in the setup process:

![Ansible admin password display](doc-images/Ansible%20Administrator%20password%20display.png)

Take the setup key (`d58cc5ca1f0440a7b7076aab1c5813d1` in the example above, but yours will be different) and put it into the password field you get when you connect to `http://<your docker host>:8080`:

![Unlock Jenkins screen](doc-images/Jenkins%20initial%20sign%20in.png)

### Choose default plugins

...unless you have something special in mind, but if you did, I doubt you'd be following this super basic process.

![Initial plugins to install](doc-images/Jenkins%20initial%20plugins.png)

The plugin process will proceed...

![Plugins installing](doc-images/Jenkins%20plugins%20installing.png)

### Create first admin user

![First admin user creation screen](doc-images/Jenkins%20first%20admin%20user.png)

Pick what you want here.

### Configure your instance hostname

This should be the same name you're using in the browser unless you have Big Plans and associated DNS entries to go along with those plans.

![Jenkins initial hostname](doc-images/Jenkins%20instance%20hostname.png)

### Welcome to the Jenkins dashboard!

This is where all the good stuff starts.

![Jenkins empty dashboard](doc-images/Jenkins%20empty%20dashboard.png)

### Start to set up a new pipeline

![Jenkins New Item](doc-images/Jenkins%20empty%20dashboard%20new%20item.png)

### Configure the pipeline name, type, and source

#### Name

![Jenkins pipeline name](doc-images/Jenkins%20new%20item%20pipeline%20name.png)

#### Type - multibranch

![Jenkins pipeline type is multibranch](doc-images/Jenkins%20new%20item%20pipeline%20type%20multibranch.png)

#### Source - GitHub

![Jenkins pipeline source from GitHub](doc-images/Jenkins%20new%20item%20branch%20source.png)

You'll get into the specifics here shortly, this is just so Jenkins knows what questions to ask.

### Job credential config

This is used for Jenkins to contact GitHub and pull details out of the GitHub repo containing the `Jenkinsfile` that describes what the pipeline does.

A global credential will allow other jobs to reach additional GitHub repos under the same owner.

![Jenkins global credential setup](doc-images/Jenkins%20job%20credential%20-%20global.png)

For the details you'll need the following:
* scope: Global (unless you have other plans)
* username: your GitHub login username
* password: the API key you created (**NOT YOUR GITHUB PASSWORD**)
* ID: a made up word uniquely identifying this GitHub API key
* Description: a made up phrase describing this GitHub API key

![Jenkins global credential details](doc-images/Jenkins%20job%20credential%20details.png)

Even though you just created this new credential to use, and it would be obvious that you now wanted to use it for this job, Jenkins does not select it by default. Ensure this new credential is the one in use to avoid delays from "anonymous" queries of GitHub later on.

![Jenkins global credential added](doc-images/Jenkins%20job%20credential%20added.png)

### Jenkins job GitHub config

Once you type in the owner of the GitHub repo (probably the same as the GitHub username earlier, unless you have a complex Organization-based setup going) Jenkins will query GitHub for a list of your repositories and they will appear as a pull-down under "Repository."

![Jenkins GitHub owner and repository](doc-images/Jenkins%20job%20GitHub%20config.png)

## Jenkins first build results

### Good news!

![Jenkins build worked!](doc-images/Jenkins%20first%20build%20--%20good%20news.png)

You can see the Docker image Go reporting back in the console log:

![Jenkins console log from a successful build](doc-images/Jenkins%20first%20build%20console%20--%20working.png)

### Bad news!

Sometimes things just don't go well. You'll see lots of red and nasty thunderstorm clouds when that happens:

![Jenkins build worked!](doc-images/Jenkins%20first%20build%20--%20bad%20news.png)

The console log is even **MORE** useful when this happens. This was how I figured out all those extra steps to put in the Ansible config.

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

## (Optional) Set up encrypted filesystems

Sometimes sensitive information like passwords must be stored encrypted, depending on specific nontechnical requirements.

### Ansible Vault password is cleartext

The Ansible vault password is stored in cleartext.

### Jenkins credential passwords temporarily cleartext

In order to create credentials the Groovy script needs to be created with the cleartext credentials embedded within it. 

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

# Configure Jenkins inside container (abandoned)

This is no longer being attempted via automation as the effort level was too high for a "Hello, world" level demonstration.

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

## Jenkins credentials

Before a job can be created that uses credentials (e.g. the github.com login) those credentials need to be created. I found some good info at https://stackoverflow.com/questions/35025829/i-want-to-create-jenkins-credentials-via-ansible.

### Passing the credential info to the Groovy script

It doesn't look like there's a way to directly run a file through the Jinja2 template processor while feeding it to a command, so the steps would be:
1. Allocate a temp file
2. Process a Jinja2 template into the temp file, adding credentials (they will be stored as cleartext, temporarily)
3. Use the CLI "groovy" command to run the credential add Groovy script
4. (optional) overwrite the temp file with junk data to confound recovery of the password from a "deleted" file
5. Delete the temp file

## Jenkins Job

The CLI manages jobs via raw XML files.

https://stackoverflow.com/questions/8424228/export-import-jobs-in-jenkins

It does not appear to be possible to define a new job using the CLI except by XML import. Note that the XML would be exceedingly difficult to craft by hand, if not outright impossible, due to its dependencies on specific internally referenced ID numbers.

Better options for creating jobs:
* https://jenkins.io/solutions/pipeline/
* https://wiki.jenkins.io/display/JENKINS/Job+DSL+Plugin (still requires a freestyle "seed" project manually created via GUI)
* https://docs.openstack.org/infra/jenkins-job-builder/ (looks especially promising as its whole job is to turn YAML/JSON into the convoluted Jenkins XML.)

It would be interesting to see how well an export from one environment (e.g. sandbox) and and import into a new environment (e.g. staging) using the job export/import would work out.

## Jenkins job fixes

Job comes up claiming that re-indexing needs to happen.

It looks like the credentials in the job XML aren't enough to work. (Those embedded IDs are rearing their ugly head.)

https://stackoverflow.com/questions/41579229/triggering-branch-indexing-on-multibranch-pipelines-jenkins-git

Exported credentials via XML also appear insufficient and the whole thing snowballed badly. Abandon this effort vs. continuing down the yak-shaving path.

# Check build log

Good news:

    + go version
    go version go1.12.1 linux/amd64

# Why all this?

## Explore Jenkins Setup

I thought this would be a quick and easy thing to try out, after all, Jenkins had a well-made Docker container available and the "Hello, world" nature of the exercise seems very simple.

I was wrong.

Just getting a Docker host set up ended up being a bit of an adventure, and it's not documented here because much of it was probably self-inflicted from trying to use one OS image for too many things. However, since I don't have the money to pay for an electricity bill any larger than it already is, I try to do as much as possible on one server.

## Docker images side by side

Getting one Docker container to tell the host how to create other Docker containers should have been pretty simple. The problem is the volume mapping makes no allowance for a GID mismatch between the container host and the containers themselves. Since I can't confirm that every possible container will agree on a GID for the "docker" user (and the owner of the docker IPC socket) it quickly became clear that I'd be reconfiguring a lot of containers.

Any time I need to do something a lot, I think of automation. And Ansible works nicely for automation.

## Inspec

Since I'm trying to encourage myself to use Behavior Driven Infrastructure Development, this was a good place to start. Define what I think the host should look like and then write some tests to confirm it. We'll see how well this helps when I get to the aforementioned "set it all up again starting from nothing" phase. For now, this was mostly just a chance to learn Inspec a bit better by having a project that required it.

# Stop Shaving the Yak

https://seths.blog/2005/03/dont_shave_that/

OK, this has snowballed well away from my original goal of learning Jenkins into learning a lot more about Ansible. While not necessarily bad, it's not what I had planned when I started. Go for a manual Jenkins setup and start exploring the Joy of Jenkinsfiles (and possibly Jenkins Job Builder) instead of this auto-build segway.