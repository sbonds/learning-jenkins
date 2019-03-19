# RHEL7 Jenkins in Docker

Check that the host server appears set up to run a Jenkins instance inside Docker.

Before you can run inspec checks, it does itself need to be installed:

    # yum install inspec

Run the checks via:

    $ inspec exec --color rhel7_docker

