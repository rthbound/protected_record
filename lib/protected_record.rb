Dir.glob(File.join(File.dirname(__FILE__), '/**/*.rb')) do |c|
  require(c)
end
