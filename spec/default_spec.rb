# encoding: utf-8
require 'chefspec'
require 'spec_helper'
require 'fauxhai'

describe 'cloudwatch-linux::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new }  
  it 'installs perl-Switch' do
    chef_run.node.set['cloud']['provider'] = 'ec2'
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package('perl-Switch')
  end
  
  it 'installs perl-Sys-Syslog' do
    chef_run.node.set['cloud']['provider'] = 'ec2'
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package('perl-Sys-Syslog')
  end
  it 'installs perl-LWP-Protocol-https' do
    chef_run.node.set['cloud']['provider'] = 'ec2'
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package('perl-LWP-Protocol-https')
  end 
  it 'includes the `ark` recipe' do
    chef_run.node.set['cloud']['provider'] = 'ec2'
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('ark')
  end

  it 'should run ark' do
    chef_run.node.set['cloud']['provider'] = 'ec2'
    chef_run.converge(described_recipe)
    expect(chef_run).to put_ark('CloudWatchMonitoringScripts-v1.1.0').with(
          url: 'http://ec2-downloads.s3.amazonaws.com/cloudwatch-samples/CloudWatchMonitoringScripts-v1.1.0.zip',
          path: '/root',
          action: [:put]
        )
  end

  it 'creates a cron autoscaling-stats' do
    chef_run.node.set['cloud']['provider'] = 'ec2'
    chef_run.converge(described_recipe)
    expect(chef_run).to create_cron('autoscaling-stats').with(
      minute: '*/5',
      command: '/root/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --auto-scaling=only --from-cron'
    )
  end

  it 'creates a cron instance-stats' do
    chef_run.node.set['cloud']['provider'] = 'ec2'
    chef_run.converge(described_recipe)
    expect(chef_run).to create_cron('instance-stats').with(
      minute: '*/5',
      command: '/root/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --from-cron'
    )
  end
end