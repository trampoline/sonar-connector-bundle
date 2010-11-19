$: << File.expand_path("..", __FILE__)
require 'jruby_boot'

c = Sonar::Connector::Controller.new File.join(CONNECTOR_ROOT, 'config', 'config.json')
c.start
