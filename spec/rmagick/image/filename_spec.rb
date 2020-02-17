RSpec.describe Magick::Image, '#filename' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.filename }.not_to raise_error
    expect(image.filename).to eq('')
    expect { image.filename = 'xxx' }.to raise_error(NoMethodError)
  end
end
