RSpec.describe Magick::Image, '#base_filename' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.base_filename }.not_to raise_error
    expect(image.base_filename).to eq('')
    expect { image.base_filename = 'xxx' }.to raise_error(NoMethodError)
  end
end
