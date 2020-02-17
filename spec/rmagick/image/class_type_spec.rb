RSpec.describe Magick::Image, '#class_type' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.class_type }.not_to raise_error
    expect(image.class_type).to be_instance_of(Magick::ClassType)
    expect(image.class_type).to eq(Magick::DirectClass)
    expect { image.class_type = Magick::PseudoClass }.not_to raise_error
    expect(image.class_type).to eq(Magick::PseudoClass)
    expect { image.class_type = 2 }.to raise_error(TypeError)

    image.class_type = Magick::PseudoClass
    image.class_type = Magick::DirectClass
    expect(image.class_type).to eq(Magick::DirectClass)
  end
end
