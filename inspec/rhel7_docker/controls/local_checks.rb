# encoding: utf-8
# copyright: 2018, Steve Bonds
#subnet = attribute('local_subnet', description: 'local subnet in IP/bits format')

title 'Checks of the local host for running Jenkins in Docker'


control 'software_installed' do
  title 'Check that needed software is installed'
  describe package('docker') do
    it { should be_installed }
    its ('version') { should cmp >= '1.13' }
  end
  describe package('ansible') do
    it { should be_installed }
    its ('version') { should cmp >= '2.7.8-0' }
  end
  describe package('python-docker-py') do
    it { should be_installed }
    its ('version') { should cmp >= '1.10.6-0' }
  end
  describe package('java-1.8.0-openjdk-headless') do
    it { should be_installed }
    its ('version') { should cmp >= '1.8.0' }
  end
end

# Ansible will later insist on running as this user
control 'jenkins_user' do
  title "Check that a 'jenkins' UNIX user exists"
  describe user('jenkins') do
    it {should exist }
    its('groups') { should include 'docker' }
  end
end

control 'docker_group' do
  title "Check that a 'docker' UNIX group exists"
  describe group('docker') do
    it {should exist }
    its('members') { should include 'jenkins' }
  end
end

# Arguably the default doesn't really need to be public, but this lets
# me be sure which zone to check as Inspec doesn't seem to have a way
# to refer to the default zone for later checks.
=begin
describe firewalld do
  title "Check that firewall ports are open to the Jenkins container from a local subnet (BUGGY: requires root)"
  # https://github.com/firewalld/firewalld/issues/111
  # https://bugzilla.redhat.com/show_bug.cgi?id=1375655
  it { should be_running }
  its('default_zone') { should eq 'public' }
  it { should have_rule_enabled('family=ipv4 source address=' + subnet + ' port port=8080 protocol=tcp accept', 'public') }
  it { should have_rule_enabled('family=ipv4 source address=' + subnet + ' port port=50000 protocol=tcp accept', 'public') }
end
=end

control 'docker_container' do
  title "Check that the 'jenkins' Docker container was created"
  describe docker_container(name: 'jenkins') do
    its('id') { should_not eq '' }
    its('image') { should eq 'jenkinsci/blueocean' }
    its('ports') { should include '0.0.0.0:8080->8080/tcp' }
    its('ports') { should include '0.0.0.0:50000->50000/tcp' }
  end

  # Sadly, docker_container does not include volume info even though
  # docker.containers does. 
  # Does not work: 
  #   its('volumes') { should include '/var/run/docker.sock' }
  describe docker.object(docker_container(name: 'jenkins').id).Config.Volumes do
    it { should include '/var/run/docker.sock' }
  end
end
