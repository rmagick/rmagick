RSpec.describe Magick::Image, '#signature' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.signature
    expect(result).to be_instance_of(String)
  end
end
