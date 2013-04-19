require "protected_record/use_case/base"

Dir.glob(File.join(File.dirname(__FILE__), '/**/*.rb')) do |c|
  require(c)
end
