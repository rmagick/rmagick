require 'timeout'

RSpec.describe Magick::Image, '#read' do
  describe 'issue #200' do
    it 'raise error with nil argument' do
      expect { described_class.read(nil) }.to raise_error(ArgumentError)
    end
  end

  describe 'issue #483', unsupported_before('6.9.0') do
    # The newer Ghostscript might not be worked with old ImageMagick.
    it 'can read PDF file' do
      expect { described_class.read(File.join(FIXTURE_PATH, 'sample.pdf')) }.not_to raise_error
    end
  end
end
