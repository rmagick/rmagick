# frozen_string_literal: true

RSpec.describe Magick::ImageList, "#optimize_layers" do
  it "works" do
    image_list = described_class.new

    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    Magick::LayerMethod.values do |method|
      next if [Magick::UndefinedLayer, Magick::CompositeLayer].include?(method)

      result = image_list.optimize_layers(method)
      expect(result).to be_instance_of(described_class)
      expect(result.length).to be_kind_of(Integer)
    end

    expect { image_list.optimize_layers(Magick::CompareClearLayer) }.not_to raise_error
    expect { image_list.optimize_layers(Magick::UndefinedLayer) }.to raise_error(ArgumentError)
    expect { image_list.optimize_layers(2) }.to raise_error(TypeError)
    expect { image_list.optimize_layers(Magick::CompositeLayer) }.to raise_error(NotImplementedError)
  end

  it "moves copies of the images onto their minimal canvas with TrimBoundsLayer, even if one is frozen meanwhile" do
    image_list = described_class.new
    image_list << Magick::Image.new(4, 4) << Magick::Image.new(4, 4)
    image_list[0].page = Magick::Rectangle.new(4, 4, 10, 10)
    image_list[1].page = Magick::Rectangle.new(4, 4, 20, 20)

    result = during_call(-> { image_list[0].freeze }) { image_list.optimize_layers(Magick::TrimBoundsLayer) }

    pages = ->(list) { list.to_a.map { |image| [image.page.width, image.page.height, image.page.x, image.page.y] } }
    expect(pages.call(result)).to eq([[14, 14, 0, 0], [14, 14, 10, 10]])
    expect(image_list[0]).to be_frozen
    expect(pages.call(image_list)).to eq([[4, 4, 10, 10], [4, 4, 20, 20]])
  end
end
