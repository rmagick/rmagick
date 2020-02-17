RSpec.describe Magick::Image, '#directory' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.directory }.not_to raise_error
    expect(image.directory).to be(nil)
    expect { image.directory = nil }.to raise_error(NoMethodError)
  end
end
