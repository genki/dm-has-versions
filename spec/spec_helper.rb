$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'merb-core'
require 'dm-core'
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks
require 'dm-has-versions/has/versions'
require 'dm-aggregates'

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
DataMapper::Model.append_extensions DataMapper::Has::Versions
Merb.disable(:initfile)
Merb.start_environment(
  :testing      => true,
  :adapter      => 'runner',
  :environment  => ENV['MERB_ENV'] || 'test',
  :merb_root    => File.dirname(__FILE__) / 'fixture',
  :log_file     => File.dirname(__FILE__) / "merb_test.log"
)
DataMapper.setup(:default, "sqlite3::memory:")

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)

  DataMapper.auto_migrate!
end
