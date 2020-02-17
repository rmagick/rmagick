RSpec.describe Magick::Image, '#implode' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.implode(0.5)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.implode(0.5, 0.5) }.to raise_error(ArgumentError)
  end
end
