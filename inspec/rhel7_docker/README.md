# RHEL7 Jenkins in Docker

Check that the host server appears set up to run a Jenkins instance inside Docker.

Before you can run inspec checks, it does itself need to be installed:

    # yum install inspec

Run the checks via:

    $ inspec exec --color rhel7_docker --attrs=rhel7_docker/attributes.yml 

The `--attrs` must come after the directory or you get this error:

    Cannot find parser for attributes file 'rhel7_docker'.

# `attributes.yml` contents

This defines local variables specific to a given environment but which (probably) should not be in Git.

Sample:

    local_subnet: 10.1.2.0/24
