RSpec.describe Magick::Image, '#directory' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.directory }.not_to raise_error
    expect(img.directory).to be(nil)
    expect { img.directory = nil }.to raise_error(NoMethodError)
  end
end
