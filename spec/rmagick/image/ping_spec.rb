# frozen_string_literal: true

RSpec.describe Magick::Image, '#ping' do
  it 'returns an image from the source, omitting pixel data' do
    result = described_class.ping(IMAGES_DIR + '/Button_0.gif')
    expect(result).to be_instance_of(Array)
    image = result.first
    expect(image).to be_instance_of(described_class)
    expect(image.format).to eq 'GIF'
    expect(image.columns).to eq 127
    expect(image.rows).to eq 120
    expect(image.filename).to match(/Button_0.gif/)
  end

  it 'raises an error when the filename contains a null byte' do
    expect { described_class.ping("#{IMAGES_DIR}/Button_0.gif\0.png") }.to raise_error(ArgumentError)
  end

  it "frees the images it read when one of its calls is interrupted" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "image.miff")
      source = described_class.new(64, 64)
      source.write(path)
      source.destroy!
      GC.start
      baseline = Magick.resource_usage(:memory)
      calls = interrupt_each_call(Class.new(StandardError)) do
        described_class.ping(path) { |options| options.colorspace = Magick::GRAYColorspace }
      end
      3.times { GC.start }

      expect(calls).to be_positive
      expect(Magick.resource_usage(:memory)).to be <= baseline
    end
  end
end
