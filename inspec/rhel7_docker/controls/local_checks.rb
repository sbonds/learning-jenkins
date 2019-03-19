# encoding: utf-8
# copyright: 2018, Steve Bonds

title 'Checks of the local host for running Jenkins in Docker'

control 'docker_installed' do
  title 'Check that Docker is installed'
  describe package('docker') do
    it { should be_installed }
    its { version should cmp >= '1.13.1' }
  end
end
