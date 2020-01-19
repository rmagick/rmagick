RSpec.describe Magick::ImageList, '#all?' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    q = nil
    expect { q = @list.all? { |i| i.class == Magick::Image } }.not_to raise_error
    expect(q).to be(true)
  end
end
