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

  [
    ['#negate, which copies it first', ->(image) { -> { image.negate } }],
    [
      '#composite of another image, which copies that image first',
      lambda do |image|
        other = described_class.new(4, 4)
        -> { other.composite(image, 0, 0, Magick::OverCompositeOp) }
      end
    ],
    ['#to_blob, which converts its colorspace first', ->(image) { -> { image.to_blob { |options| options.colorspace = Magick::GRAYColorspace } } }],
    [
      'GradientFill#fill',
      lambda do |image|
        fill = Magick::GradientFill.new(0, 0, 4, 0, 'black', 'white')
        -> { fill.fill(image) }
      end
    ],
    [
      'Draw#draw, which copies the patterns of a frozen Draw first',
      lambda do |image|
        draw = Magick::Draw.new
        draw.fill_pattern = described_class.new(2, 2)
        draw.rectangle(0, 0, 2, 2)
        draw.freeze
        -> { draw.draw(image) }
      end
    ],
    [
      'ImageList#append, which copies a frozen image of the list',
      lambda do |image|
        image_list = Magick::ImageList.new.push(image, described_class.new(4, 4).freeze)
        -> { image_list.append(false) }
      end
    ]
  ].each do |name, prepare|
    it "raises instead of destroying the image while #{name} uses it" do
      image = described_class.new(4, 4)
      call = prepare.call(image)

      expect { during_call(-> { image.destroy! }) { call.call } }.to raise_error(RuntimeError, 'object is in use by another fiber')
      expect(image.destroyed?).to be(false)
    end
  end
end
