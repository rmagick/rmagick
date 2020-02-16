RSpec.describe Magick::Image, '#unique_colors' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.unique_colors
      expect(res).to be_instance_of(described_class)
      expect(res.columns).to eq(1)
      expect(res.rows).to eq(1)
    end.not_to raise_error
  end
end
