$: << File.expand_path("..", __FILE__)
require 'jruby_boot'
require 'irb'

c = Sonar::Connector::Controller.new File.join(CONNECTOR_ROOT, 'config', 'config.json')
c.start_console
IRB.start
