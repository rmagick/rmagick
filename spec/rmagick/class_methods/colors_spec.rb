# frozen_string_literal: true

require "open3"
require "tmpdir"

RSpec.describe Magick, '.colors' do
  it 'works' do
    result = described_class.colors
    expect(result).to be_instance_of(Array)
    result.each do |c|
      expect(c).to be_instance_of(Magick::Color)
      expect(c.name).to be_instance_of(String)
      expect(c.compliance).to be_instance_of(Magick::ComplianceType) unless c.compliance.nil?
      expect(c.color).to be_instance_of(Magick::Pixel)
    end
    described_class.colors { |c| expect(c).to be_instance_of(Magick::Color) }
  end

  it "returns nil for the name of a color that has none" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "colors.xml"), <<~XML)
        <?xml version="1.0"?>
        <colormap>
          <color color="rgb(1,2,3)" compliance="SVG"/>
        </colormap>
      XML
      script = "color = Magick.colors.find { |c| c.name.nil? }; Magick.colors { |_| nil }; print color.color.to_color(Magick::AllCompliance, false, 8, true)"
      command = [RbConfig.ruby, "-I", File.expand_path("../../../lib", __dir__), "-r", "rmagick", "-e", script]

      output, errors, status = Open3.capture3({ "MAGICK_CONFIGURE_PATH" => dir }, *command)

      expect(status).to be_success, errors
      expect(output).to eq("#010203")
    end
  end

  it "returns the value that the block breaks with" do
    color = described_class.colors { |c| break c }

    expect(color).to be_instance_of(Magick::Color)
  end
end
