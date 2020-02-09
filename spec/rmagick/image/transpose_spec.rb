RSpec.describe Magick::Image, '#transpose' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.transpose
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect do
      res = @img.transpose!
      expect(res).to be_instance_of(described_class)
      expect(res).to be(@img)
    end.not_to raise_error
  end
end
