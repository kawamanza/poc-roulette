require 'rubygems'
require 'activesupport'
Dir.glob(File.join File.dirname(__FILE__), 'util', '*.rb').each do |file|
  require file
end

# Loading API
%w[
  bet
  number
  strategy
].each do |file|
  require File.join(File.dirname(__FILE__), file)
end

# Loading params
config_file = "config/roulette.yml"
unless File.exists? config_file
  ccputs "{red}config file does not exists:", "{yellow}#{config_file}"
  exit 1
end
require 'yaml'
ccputs "{green}Loading #{config_file}"
config = YAML::load_file config_file

