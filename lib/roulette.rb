require 'rubygems'
require 'activesupport'
Dir.glob(File.join File.dirname(__FILE__), 'util', '*.rb').each do |file|
  require file
end

# Loading API
%w[
  bet
  number
  dealer
  strategy
  bet_handle
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
PocConfig = YAML::load_file config_file

require 'optparse'
OptionParser.new do |parser|
  parser.banner = "Usage: #{File.basename($0)} [OPTIONS]"
  parser.separator "\nOPTIONS:"
  parser.on("-h", "--help", "This message") do
    puts parser
    exit
  end
  parser.on("-c", "--with-chips=CHIPS", "Set the initial chips") do |chips|
    PocConfig['roulette']['initial_chips'] = chips.to_i
  end
  parser.on("-b", "--total-bets=BETS", "Set the total bets") do |bets|
    PocConfig['roulette']['total_bets'] = bets.to_i
  end
  parser.on("-u", "--debugger", "Enable ruby-debugging") do
    require 'ruby-debug'
  end
  parser.on("-s", "--strategy=STRATEGY", "Set the strategy") do |strategy|
    PocConfig['roulette']['strategy'] = strategy
  end
end.parse!
