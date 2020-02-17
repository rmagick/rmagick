RSpec.describe Magick::Image, '#distortion_channel' do
  it 'works' do
    image1 = described_class.new(20, 20)

    metric = image1.distortion_channel(image1, Magick::MeanAbsoluteErrorMetric)
    expect(metric).to be_instance_of(Float)
    expect(metric).to eq(0.0)

    expect { image1.distortion_channel(image1, Magick::MeanSquaredErrorMetric) }.not_to raise_error
    expect { image1.distortion_channel(image1, Magick::PeakAbsoluteErrorMetric) }.not_to raise_error
    expect { image1.distortion_channel(image1, Magick::PeakSignalToNoiseRatioErrorMetric) }.not_to raise_error
    expect { image1.distortion_channel(image1, Magick::RootMeanSquaredErrorMetric) }.not_to raise_error
    expect { image1.distortion_channel(image1, Magick::MeanSquaredErrorMetric, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { image1.distortion_channel(image1, Magick::NormalizedCrossCorrelationErrorMetric) }.not_to raise_error
    expect { image1.distortion_channel(image1, Magick::FuzzErrorMetric) }.not_to raise_error
    expect { image1.distortion_channel(image1, 2) }.to raise_error(TypeError)
    expect { image1.distortion_channel(image1, Magick::RootMeanSquaredErrorMetric, 2) }.to raise_error(TypeError)
    expect { image1.distortion_channel }.to raise_error(ArgumentError)
    expect { image1.distortion_channel(image1) }.to raise_error(ArgumentError)

    image2 = described_class.new(20, 20)
    image2.destroy!
    expect { image1.distortion_channel(image2, Magick::MeanSquaredErrorMetric) }.to raise_error(Magick::DestroyedImageError)
  end
end
