RSpec.describe Magick::Image, '#contrast' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.contrast
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.contrast(true) }.not_to raise_error
    expect { image.contrast(true, 2) }.to raise_error(ArgumentError)
  end
end
