RSpec.describe Magick::Image, '#dispose' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.dispose }.not_to raise_error
    expect(image.dispose).to be_instance_of(Magick::DisposeType)
    expect(image.dispose).to eq(Magick::UndefinedDispose)
    expect { image.dispose = Magick::NoneDispose }.not_to raise_error
    expect(image.dispose).to eq(Magick::NoneDispose)

    Magick::DisposeType.values do |dispose|
      expect { image.dispose = dispose }.not_to raise_error
    end
    expect { image.dispose = 2 }.to raise_error(TypeError)
  end
end
