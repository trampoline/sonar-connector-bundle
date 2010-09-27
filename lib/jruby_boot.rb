BUNDLER_VERSION = "bundler-1.0.0"

CONNECTOR_ROOT = File.expand_path( File.join File.dirname(__FILE__), '..' )
Dir.chdir CONNECTOR_ROOT

BUNDLER_PATH = "file:#{File.join(CONNECTOR_ROOT, 'lib', 'jruby-complete.jar')}!/META-INF/jruby.home/lib/ruby/gems/1.8/gems/#{BUNDLER_VERSION}/lib"
$:.unshift(BUNDLER_PATH)

require 'bundler/setup'
require 'sonar_connector'
c = Sonar::Connector::Controller.new File.join(CONNECTOR_ROOT, 'config', 'config.json')
c.start
