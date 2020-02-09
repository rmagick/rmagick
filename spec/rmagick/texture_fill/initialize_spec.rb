RSpec.describe Magick::TextureFill, '#initialize' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    expect(described_class.new(granite)).to be_instance_of(described_class)
  end
end
