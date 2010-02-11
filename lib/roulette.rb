Dir.glob(File.join File.dirname(__FILE__), 'util', '*.rb').each do |file|
  require file
end
