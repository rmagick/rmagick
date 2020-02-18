RSpec.describe Magick::ImageList, "#optimize_layers" do
  it "works" do
    image_list = described_class.new

    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    Magick::LayerMethod.values do |method|
      next if [Magick::UndefinedLayer, Magick::CompositeLayer, Magick::TrimBoundsLayer].include?(method)

      result = image_list.optimize_layers(method)
      expect(result).to be_instance_of(described_class)
      expect(result.length).to be_kind_of(Integer)
    end

    expect { image_list.optimize_layers(Magick::CompareClearLayer) }.not_to raise_error
    expect { image_list.optimize_layers(Magick::UndefinedLayer) }.to raise_error(ArgumentError)
    expect { image_list.optimize_layers(2) }.to raise_error(TypeError)
    expect { image_list.optimize_layers(Magick::CompositeLayer) }.to raise_error(NotImplementedError)
  end
end
