RSpec.describe Magick::Image, '#signature' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.signature
    expect(res).to be_instance_of(String)
  end
end
