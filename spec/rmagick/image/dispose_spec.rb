RSpec.describe Magick::Image, '#dispose' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.dispose }.not_to raise_error
    expect(@img.dispose).to be_instance_of(Magick::DisposeType)
    expect(@img.dispose).to eq(Magick::UndefinedDispose)
    expect { @img.dispose = Magick::NoneDispose }.not_to raise_error
    expect(@img.dispose).to eq(Magick::NoneDispose)

    Magick::DisposeType.values do |dispose|
      expect { @img.dispose = dispose }.not_to raise_error
    end
    expect { @img.dispose = 2 }.to raise_error(TypeError)
  end
end
