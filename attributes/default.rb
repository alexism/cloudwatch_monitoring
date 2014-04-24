

default[:cw_mon][:user]              = "cw_monitoring"
default[:cw_mon][:group]             = "cw_monitoring"
default[:cw_mon][:as_system]         = false
default[:cw_mon][:home_dir]          = "/home/#{node[:cw_mon][:user]}"
default[:cw_mon][:version]           = "1.1.0"
default[:cw_mon][:release_url]       = "http://ec2-downloads.s3.amazonaws.com/cloudwatch-samples/CloudWatchMonitoringScripts-v1.1.0.zip"


default[:cw_mon][:aws_users_databag] = "aws_users"
default[:cw_mon][:access_key_id]     = nil
default[:cw_mon][:secret_access_key] = nil

default[:cw_mon][:options] = %w{--disk-space-util  --disk-path=/ --disk-space-used
                                --disk-space-avail --swap-util --swap-used
                                --mem-util --mem-used --mem-avail}

default[:cw_mon][:cron_minutes] = 5
