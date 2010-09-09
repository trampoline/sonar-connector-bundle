BUNDLER_VERSION = "bundler-1.0.0"

BUNDLER_PATH = "file:#{File.expand_path("lib/jruby-complete.jar", Dir.pwd)}!/META-INF/jruby.home/lib/ruby/gems/1.8/gems/#{BUNDLER_VERSION}/lib"

$:.unshift(BUNDLER_PATH)
require 'bundler/setup'
require 'sonar_connector'
c = Sonar::Connector::Controller.new('config/config.json')
c.start
