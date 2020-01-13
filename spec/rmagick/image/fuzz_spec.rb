RSpec.describe Magick::Image, '#fuzz' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.fuzz }.not_to raise_error
    expect(@img.fuzz).to be_instance_of(Float)
    expect(@img.fuzz).to eq(0.0)
    expect { @img.fuzz = 50 }.not_to raise_error
    expect(@img.fuzz).to eq(50.0)
    expect { @img.fuzz = '50%' }.not_to raise_error
    expect(@img.fuzz).to be_within(0.1).of(Magick::QuantumRange * 0.50)
    expect { @img.fuzz = [] }.to raise_error(TypeError)
    expect { @img.fuzz = 'xxx' }.to raise_error(ArgumentError)
  end
end
