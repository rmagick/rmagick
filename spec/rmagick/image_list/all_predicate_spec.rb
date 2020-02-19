RSpec.describe Magick::ImageList, '#all?' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    q = nil
    expect { q = image_list.all? { |i| i.class == Magick::Image } }.not_to raise_error
    expect(q).to be(true)
  end
end
