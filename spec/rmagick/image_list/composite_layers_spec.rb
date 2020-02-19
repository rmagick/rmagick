RSpec.describe Magick::ImageList, '#composite_layers' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image_list2 = described_class.new # intersection is 5..9
    image_list2 << image_list[5]
    image_list2 << image_list[6]
    image_list2 << image_list[7]
    image_list2 << image_list[8]
    image_list2 << image_list[9]

    expect { image_list.composite_layers(image_list2) }.not_to raise_error
    Magick::CompositeOperator.values do |op|
      expect { image_list.composite_layers(image_list2, op) }.not_to raise_error
    end

    expect { image_list.composite_layers(image_list2, Magick::ModulusAddCompositeOp, 42) }.to raise_error(ArgumentError)
  end
end
