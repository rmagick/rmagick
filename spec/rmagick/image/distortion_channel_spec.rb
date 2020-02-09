RSpec.describe Magick::Image, '#distortion_channel' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      metric = @img.distortion_channel(@img, Magick::MeanAbsoluteErrorMetric)
      expect(metric).to be_instance_of(Float)
      expect(metric).to eq(0.0)
    end.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::MeanSquaredErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::PeakAbsoluteErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::PeakSignalToNoiseRatioErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::RootMeanSquaredErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::MeanSquaredErrorMetric, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::NormalizedCrossCorrelationErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::FuzzErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, 2) }.to raise_error(TypeError)
    expect { @img.distortion_channel(@img, Magick::RootMeanSquaredErrorMetric, 2) }.to raise_error(TypeError)
    expect { @img.distortion_channel }.to raise_error(ArgumentError)
    expect { @img.distortion_channel(@img) }.to raise_error(ArgumentError)

    img = described_class.new(20, 20)
    img.destroy!
    expect { @img.distortion_channel(img, Magick::MeanSquaredErrorMetric) }.to raise_error(Magick::DestroyedImageError)
  end
end
