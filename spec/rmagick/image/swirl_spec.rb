RSpec.describe Magick::Image, '#swirl' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.swirl(30)
    expect(res).to be_instance_of(described_class)
  end
end
