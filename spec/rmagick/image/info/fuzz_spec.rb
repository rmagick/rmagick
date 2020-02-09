RSpec.describe Magick::Image::Info, '#fuzz' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.fuzz = 50 }.not_to raise_error
    expect(@info.fuzz).to eq(50)
    expect { @info.fuzz = '50%' }.not_to raise_error
    expect(@info.fuzz).to eq(Magick::QuantumRange * 0.5)
    expect { @info.fuzz = nil }.to raise_error(TypeError)
    expect { @info.fuzz = 'xxx' }.to raise_error(ArgumentError)
  end
end
