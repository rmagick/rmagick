# frozen_string_literal: true

RSpec.describe Magick::Image, '#destroy!' do
  it 'works' do
    unmapped = Magick::ImageList.new(IMAGES_DIR + '/Hot_Air_Balloons.jpg', IMAGES_DIR + '/Violin.jpg', IMAGES_DIR + '/Polynesia.jpg')
    map = Magick::ImageList.new 'netscape:'
    mapped = unmapped.remap map
    unmapped.each(&:destroy!)
    map.destroy!
    mapped.each(&:destroy!)
  end

  it 'raises instead of destroying the image while a call uses it' do
    image = described_class.new(4, 4)

    expect { during_call(-> { image.destroy! }) { image.blur_image } }.to raise_error(RuntimeError, 'object is in use by another fiber')
    expect(image.destroyed?).to be(false)
  end

  it 'raises instead of destroying the image before a bang method replaces it' do
    image = described_class.new(4, 4)

    expect { during_call(-> { image.destroy! }, event: :c_return) { image.resize!(2, 2) } }.to raise_error(RuntimeError, 'object is in use by another fiber')
    expect([image.columns, image.rows]).to eq([4, 4])
  end
end
