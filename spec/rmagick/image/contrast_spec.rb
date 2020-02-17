RSpec.describe Magick::Image, '#contrast' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.contrast
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    expect { img.contrast(true) }.not_to raise_error
    expect { img.contrast(true, 2) }.to raise_error(ArgumentError)
  end
end
