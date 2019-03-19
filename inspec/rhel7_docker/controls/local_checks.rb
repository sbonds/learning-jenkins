# encoding: utf-8
# copyright: 2018, Steve Bonds

title 'Checks of the local host for running Jenkins in Docker'

control 'software_installed' do
  title 'Check that needed software is installed'
  describe package('docker') do
    it { should be_installed }
    its ('version') { should cmp >= '1.13' }
  end
  describe package('ansible') do
    it { should be_installed }
    its ('version') { should cmp >= '2.7.8' }
  end
  describe package('java') do
    it { should be_installed }
    its ('version') { should cmp >= '1.8.0' }
  end
end
