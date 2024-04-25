RSpec.describe Magick::ImageList, '#destroyed?' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect(image_list.destroyed?).to be(false)

    image_list.to_a.first.destroy!
    expect(image_list.destroyed?).to be(false)

    image_list.destroy!
    expect(image_list.destroyed?).to be(true)
  end
end
