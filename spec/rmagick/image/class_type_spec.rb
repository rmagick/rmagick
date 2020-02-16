RSpec.describe Magick::Image, '#class_type' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.class_type }.not_to raise_error
    expect(img.class_type).to be_instance_of(Magick::ClassType)
    expect(img.class_type).to eq(Magick::DirectClass)
    expect { img.class_type = Magick::PseudoClass }.not_to raise_error
    expect(img.class_type).to eq(Magick::PseudoClass)
    expect { img.class_type = 2 }.to raise_error(TypeError)

    expect do
      img.class_type = Magick::PseudoClass
      img.class_type = Magick::DirectClass
      expect(img.class_type).to eq(Magick::DirectClass)
    end.not_to raise_error
  end
end
