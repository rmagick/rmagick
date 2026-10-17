# frozen_string_literal: true

RSpec.describe Magick::Image, '#from_blob' do
  it 'returns an image equal to the original' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    blob = image.to_blob

    expect(blob).to be_instance_of(String)
    result = described_class.from_blob(blob)
    expect(result).to be_instance_of(Array)
    expect(result.first).to be_instance_of(described_class)
    expect(result.first).to eq image
  end

  it 'sync Image::Info' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    blob = image.to_blob

    result = described_class.from_blob(blob) do |options|
      options.colorspace = Magick::LabColorspace
    end
    expect(result.first.colorspace).to eq(Magick::LabColorspace)
  end

  it "frees the images it read when one of its calls is interrupted" do
    source = described_class.new(64, 64)
    blob = source.to_blob { |options| options.format = "MIFF" }
    source.destroy!
    GC.start
    baseline = Magick.resource_usage(:memory)
    calls = interrupt_each_call(Class.new(StandardError)) { described_class.from_blob(blob) { |options| options.colorspace = Magick::GRAYColorspace } }
    3.times { GC.start }

    expect(calls).to be_positive
    expect(Magick.resource_usage(:memory)).to be <= baseline
  end
end
