# frozen_string_literal: true

require "open3"
require "tmpdir"

RSpec.describe Magick, '.fonts' do
  it 'works' do
    result = described_class.fonts
    expect(result).to be_instance_of(Array)
    result.each do |f|
      expect(f).to be_instance_of(Magick::Font)
      expect(f.name).to be_instance_of(String)
      expect(f.description).to be_instance_of(String) unless f.description.nil?
      expect(f.family).to be_instance_of(String) unless f.family.nil?
      expect(f.style).to be_instance_of(Magick::StyleType) unless f.style.nil?
      expect(f.stretch).to be_instance_of(Magick::StretchType) unless f.stretch.nil?
      expect(f.weight).to be_kind_of(Integer)
      expect(f.encoding).to be_instance_of(String) unless f.encoding.nil?
      expect(f.foundry).to be_instance_of(String) unless f.foundry.nil?
      expect(f.format).to be_instance_of(String) unless f.format.nil?
    end
    described_class.fonts { |f| expect(f).to be_instance_of(Magick::Font) }
  end

  it "returns nil for the family of a font that has none" do
    Dir.mktmpdir do |dir|
      type_xml = File.join(dir, "type.xml")
      File.write(type_xml, <<~XML)
        <?xml version="1.0"?>
        <typemap>
          <type name="NoFamily-Regular" fullname="No Family Regular" glyphs="#{type_xml}"/>
        </typemap>
      XML
      script = "font = Magick.fonts.find { |f| f.name == \"NoFamily-Regular\" }; Magick.fonts { |_| nil }; print font.family.inspect"
      command = [RbConfig.ruby, "-I", File.expand_path("../../../lib", __dir__), "-r", "rmagick", "-e", script]

      output, errors, status = Open3.capture3({ "MAGICK_CONFIGURE_PATH" => dir }, *command)

      expect(status).to be_success, errors
      expect(output).to eq("nil")
    end
  end

  it "returns the value that the block breaks with" do
    font = described_class.fonts { |f| break f }

    expect(font).to be_instance_of(Magick::Font)
  end
end
