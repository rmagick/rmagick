describe Magick::Color, '#compliance' do
  it 'return expect value, not nil' do
    Magick.colors do |color|
      expect(color.compliance).not_to be(nil)
    end
  end
end
