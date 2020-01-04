RSpec.describe Magick::TextureFill, '#initialize' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    expect(Magick::TextureFill.new(granite)).to be_instance_of(Magick::TextureFill)
  end
end
