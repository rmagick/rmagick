# frozen_string_literal: true

RSpec.describe Magick::Image, '#read' do
  describe 'issue #200' do
    it 'raise error with nil argument' do
      expect { described_class.read(nil) }.to raise_error(ArgumentError)
    end
  end

  describe 'issue #483' do
    # The newer Ghostscript might not be worked with old ImageMagick.
    it 'can read PDF file', unless: -> { ENV.fetch('RMAGICK_SKIP_GHOSTSCRIPT_TEST', nil) } do
      expect { described_class.read(File.join(FIXTURE_PATH, 'sample.pdf')) }.not_to raise_error
    end
  end

  it 'raises an error when the filename contains a null byte' do
    expect { described_class.read("#{IMAGES_DIR}/Button_0.gif\0.png") }.to raise_error(ArgumentError)
  end

  it 'sync Image::Info' do
    result = described_class.read(IMAGES_DIR + '/Button_0.gif') do |options|
      options.colorspace = Magick::LabColorspace
    end
    expect(result.first.colorspace).to eq(Magick::LabColorspace)
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
        described_class.read(path) { |options| options.colorspace = Magick::GRAYColorspace }
      end
      3.times { GC.start }

      expect(calls).to be_positive
      expect(Magick.resource_usage(:memory)).to be <= baseline
    end
  end
end
