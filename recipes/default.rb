#
# Cookbook Name:: cloudwatch-linux
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if node['cloud'] && node['cloud']['provider']
  if node['cloud']['provider'] == 'ec2' # the latter check uses Ohai's cloud detection
    node['cloudwatch-linux']['packages'].each do |pkg|
      package pkg do
        action :install
      end
    end

    include_recipe 'ark'

    ark 'CloudWatchMonitoringScripts-v1.1.0' do
      url 'http://ec2-downloads.s3.amazonaws.com/cloudwatch-samples/CloudWatchMonitoringScripts-v1.1.0.zip'
      path '/root'
      action [:put]
    end

    cron 'autoscaling-stats' do
      minute '*/5'
      command '/root/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --auto-scaling=only --from-cron'
    end

    cron 'instance-stats' do
      minute '*/5'
      command '/root/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --from-cron'
    end
  end
end
