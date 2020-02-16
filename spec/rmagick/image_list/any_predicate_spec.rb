RSpec.describe Magick::ImageList, '#any?' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    q = nil
    expect { q = list.any? { |_i| false } }.not_to raise_error
    expect(q).to be(false)
    expect { q = list.any? { |i| i.class == Magick::Image } }.not_to raise_error
    expect(q).to be(true)
  end
end
