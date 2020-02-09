RSpec.describe Magick::Image, '#unique_colors' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.unique_colors
      expect(res).to be_instance_of(described_class)
      expect(res.columns).to eq(1)
      expect(res.rows).to eq(1)
    end.not_to raise_error
  end
end
