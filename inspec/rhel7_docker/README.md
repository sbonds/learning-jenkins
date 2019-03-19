# RHEL7 Jenkins in Docker

Check that the host server appears set up to run a Jenkins instance inside Docker.

Before you can run inspec checks, it does itself need to be installed:

    # yum install inspec

Run the checks via:

    $ inspec exec --color --attrs=rhel7_docker/attributes.yml rhel7_docker

# `attributes.yml` contents

This defines local variables specific to a given environment but which (probably) should not be in Git.

Sample:

    attributes:
      - name: local_subnet
        type: string
        value: 10.1.2.0/24
