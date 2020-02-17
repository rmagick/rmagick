RSpec.describe Magick::Image, '#signature' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.signature
    expect(res).to be_instance_of(String)
  end
end
