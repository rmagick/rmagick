require 'simplecov'
SimpleCov.start do
  add_group "RMagick" do |source_file|
    filename = source_file.filename
    filename.include?("/lib/") && !filename.include?("/rvg/")
  end
  add_group "Extconf", "ext/RMagick"
  add_group "RVG", "lib/rvg"
  add_group "Examples", "examples"
  add_group "Doc Examples", "doc/ex"
  add_group "Specs", "spec"
end
