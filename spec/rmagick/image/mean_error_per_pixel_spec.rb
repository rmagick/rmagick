RSpec.describe Magick::Image, '#mean_error_per_pixel' do
  before do
    @hat = described_class.read(FLOWER_HAT).first
  end

  it 'works' do
    expect { @hat.mean_error_per_pixel }.not_to raise_error
    expect { @hat.normalized_mean_error }.not_to raise_error
    expect { @hat.normalized_maximum_error }.not_to raise_error
    expect(@hat.mean_error_per_pixel).to eq(0.0)
    expect(@hat.normalized_mean_error).to eq(0.0)
    expect(@hat.normalized_maximum_error).to eq(0.0)

    hat2 = @hat.quantize(16, Magick::RGBColorspace, true, 0, true)

    expect(hat2.mean_error_per_pixel).not_to eq(0.0)
    expect(hat2.normalized_mean_error).not_to eq(0.0)
    expect(hat2.normalized_maximum_error).not_to eq(0.0)
    expect { hat2.mean_error_per_pixel = 1 }.to raise_error(NoMethodError)
    expect { hat2.normalized_mean_error = 1 }.to raise_error(NoMethodError)
    expect { hat2.normalized_maximum_error = 1 }.to raise_error(NoMethodError)
  end
end
