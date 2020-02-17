RSpec.describe Magick::Image, '#class_type=' do
  it 'does not allow setting to UndefinedClass' do
    image = described_class.new(20, 20)

    expect { image.class_type = Magick::UndefinedClass }
      .to raise_error(ArgumentError, 'Invalid class type specified.')
  end
end
