JRUBY_FILENAME = File.basename(Dir[File.expand_path("../jruby-complete-*", __FILE__)].first)
$stderr << "JRUBY_FILENAME: #{JRUBY_FILENAME}\n"
BUNDLER_VERSION = JRUBY_FILENAME[/jruby-complete-[\d\.]+-(bundler-.+)\.jar/,1]
$stderr << "BUNDLER_VERSION: #{BUNDLER_VERSION}\n"

CONNECTOR_ROOT = File.expand_path("../..", __FILE__)
Dir.chdir CONNECTOR_ROOT

BUNDLER_PATH = "file:#{File.join(CONNECTOR_ROOT, 'lib', 'jruby-complete.jar')}!/META-INF/jruby.home/lib/ruby/gems/1.8/gems/#{BUNDLER_VERSION}/lib"
$:.unshift(BUNDLER_PATH)

require 'bundler/setup'
require 'sonar_connector'
