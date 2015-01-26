#
# Cookbook Name::       cloudwatch_monitoring
# Description::         Base configuration for cloudwatch_monitoring
# Recipe::              default
# Author::              Alexis Midon
#
# See https://github.com/alexism/cloudwatch_monitoring
#
# Copyright 2013, Alexis Midon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'cron'

install_path="#{node[:cw_mon][:home_dir]}/aws-scripts-mon-v#{node[:cw_mon][:version]}"
zip_filepath="#{node[:cw_mon][:home_dir]}/CloudWatchMonitoringScripts-v#{node[:cw_mon][:version]}.zip"

case node[:platform_family]
  when 'rhel'
    %w{unzip perl-CPAN}.each do |p|
      package p
    end

    %w{Test::More Bundle::LWP5_837 Bundle::LWP}.each do |m|
      execute "install Perl module #{m}" do
        command "perl -MCPAN -e 'install #{m}' < /dev/null"
        not_if { ::File.directory?(install_path) }
      end
    end

  when 'debian'

    %w{unzip libwww-perl libcrypt-ssleay-perl libswitch-perl}.each do |p|
      package p do
        action :install
      end
    end

  else
    log "#{node[:platform_family]} is not supported" do
      level :warn
    end
end

group node[:cw_mon][:group] do
  action :create
end

user node[:cw_mon][:user] do
  home node[:cw_mon][:home_dir]
  group node[:cw_mon][:group]
  action :create
end

directory node[:cw_mon][:home_dir] do
  group node[:cw_mon][:group]
  owner node[:cw_mon][:user]
end


remote_file zip_filepath do
  source node[:cw_mon][:release_url]
  owner node[:cw_mon][:user]
  group node[:cw_mon][:group]
  mode 0755
  not_if { File.directory? install_path }
end


bash 'extract_aws-scripts-mon' do
  user node[:cw_mon][:user]
  group node[:cw_mon][:group]
  cwd ::File.dirname(zip_filepath)
  code <<-EOH
    rm -rf #{install_path}
    [[ -d #{File.dirname(install_path)} ]] || mkdir -vp #{File.dirname(install_path)}
    unzip #{zip_filepath}
    mv -v ./aws-scripts-mon #{install_path}
    chown -R #{node[:cw_mon][:user]}:#{node[:cw_mon][:group]} #{install_path}
  EOH
  not_if { File.directory? install_path }
end


file zip_filepath do
  action :delete
end

options = ['--from-cron'] + node[:cw_mon][:options]

if iam_role = IAM::role
  log "IAM role available: #{iam_role}"
else
  log "no IAM role available. CloudWatch Monitoring scripts will use IAM user #{node[:cw_mon][:user]}" do
    level :warn
  end
  vars = {}
  begin
    user_creds = Chef::EncryptedDataBagItem.load(node[:cw_mon][:aws_users_databag], node[:cw_mon][:user])
    vars[:access_key_id] = user_creds['access_key_id']
    vars[:secret_access_key] = user_creds['secret_access_key']
    log "AWS key for user #{ node[:cw_mon][:user]} found in databag #{node[:cw_mon][:aws_users_databag]}"
  rescue
    vars =node[:cw_mon]
  end

  template "#{install_path}/awscreds.conf" do
    owner node[:cw_mon][:user]
    group node[:cw_mon][:group]
    mode 0644
    source 'awscreds.conf.erb'
    variables :cw_mon => vars
  end

  options << "--aws-credential-file #{install_path}/awscreds.conf"
end

cron_d 'cloudwatch_monitoring' do
  minute "*/#{node[:cw_mon][:cron_minutes]}"
  user node[:cw_mon][:user]
  command %Q{#{install_path}/mon-put-instance-data.pl #{(options).join(' ')} || logger -t aws-scripts-mon "status=failed exit_code=$?"}
end
