RSpec.describe Magick::Image, '#endian' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.endian }.not_to raise_error
    expect(@img.endian).to be_instance_of(Magick::EndianType)
    expect(@img.endian).to eq(Magick::UndefinedEndian)
    expect { @img.endian = Magick::LSBEndian }.not_to raise_error
    expect(@img.endian).to eq(Magick::LSBEndian)
    expect { @img.endian = Magick::MSBEndian }.not_to raise_error
    expect { @img.endian = 2 }.to raise_error(TypeError)
  end
end
