RSpec.describe Magick::Image, '#shave' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.shave(5, 5)
    expect(res).to be_instance_of(described_class)
  end
end
