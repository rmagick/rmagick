RSpec.describe Magick::Image, '#distortion_channel' do
  it 'works' do
    img1 = described_class.new(20, 20)

    metric = img1.distortion_channel(img1, Magick::MeanAbsoluteErrorMetric)
    expect(metric).to be_instance_of(Float)
    expect(metric).to eq(0.0)

    expect { img1.distortion_channel(img1, Magick::MeanSquaredErrorMetric) }.not_to raise_error
    expect { img1.distortion_channel(img1, Magick::PeakAbsoluteErrorMetric) }.not_to raise_error
    expect { img1.distortion_channel(img1, Magick::PeakSignalToNoiseRatioErrorMetric) }.not_to raise_error
    expect { img1.distortion_channel(img1, Magick::RootMeanSquaredErrorMetric) }.not_to raise_error
    expect { img1.distortion_channel(img1, Magick::MeanSquaredErrorMetric, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { img1.distortion_channel(img1, Magick::NormalizedCrossCorrelationErrorMetric) }.not_to raise_error
    expect { img1.distortion_channel(img1, Magick::FuzzErrorMetric) }.not_to raise_error
    expect { img1.distortion_channel(img1, 2) }.to raise_error(TypeError)
    expect { img1.distortion_channel(img1, Magick::RootMeanSquaredErrorMetric, 2) }.to raise_error(TypeError)
    expect { img1.distortion_channel }.to raise_error(ArgumentError)
    expect { img1.distortion_channel(img1) }.to raise_error(ArgumentError)

    img2 = described_class.new(20, 20)
    img2.destroy!
    expect { img1.distortion_channel(img2, Magick::MeanSquaredErrorMetric) }.to raise_error(Magick::DestroyedImageError)
  end
end
