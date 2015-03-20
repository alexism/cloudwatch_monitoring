require 'chefspec'
require 'chefspec/berkshelf'
require 'support/matchers'

RSpec.configure do |config|
  # run all specs when using a filter, but no spec match
  config.run_all_when_everything_filtered = true
  config.log_level = :error
  config.platform = 'centos'
  config.version = '6.5'
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

at_exit { ChefSpec::Coverage.report! }
