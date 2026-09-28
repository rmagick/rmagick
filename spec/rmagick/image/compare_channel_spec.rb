# frozen_string_literal: true

RSpec.describe Magick::Image, "#compare_channel" do
  it "works" do
    image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

    Magick::MetricType.values do |metric|
      expect { image1.compare_channel(image2, metric) }.not_to raise_error
    end
    expect { image1.compare_channel(image2, 2) }.to raise_error(TypeError)
    expect { image1.compare_channel }.to raise_error(ArgumentError)

    expect { image1.compare_channel(image2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel) }.not_to raise_error
    expect { image1.compare_channel(image2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { image1.compare_channel(image2, Magick::MeanAbsoluteErrorMetric, 2) }.to raise_error(TypeError)
    expect { image1.compare_channel(image2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel, 2) }.to raise_error(TypeError)

    result = image1.compare_channel(image2, Magick::MeanAbsoluteErrorMetric)
    expect(result).to be_instance_of(Array)
    expect(result[0]).to be_instance_of(described_class)
    expect(result[1]).to be_instance_of(Float)

    image2.destroy!
    expect { image1.compare_channel(image2, Magick::MeanAbsoluteErrorMetric) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'uses highlight_color and lowlight_color' do
    image1 = described_class.new(4, 4)
    image2 = image1.copy
    image2.pixel_color(0, 0, 'blue')

    diff, = image1.compare_channel(image2, Magick::MeanAbsoluteErrorMetric) do |options|
      options.highlight_color = 'lime'
      options.lowlight_color = Magick::Pixel.from_color('yellow')
    end
    expect(diff.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('lime'))
    expect(diff.pixel_color(1, 1)).to eq(Magick::Pixel.from_color('yellow'))
  end

  it 'keeps the alpha of a pixel given as highlight_color' do
    image2 = described_class.new(4, 4)
    image2.pixel_color(0, 0, 'blue')
    translucent = Magick::Pixel.from_color('lime')
    translucent.alpha = Magick::QuantumRange / 2

    highlighted = [Magick::Pixel.from_color('lime'), translucent].map do |color|
      diff, = described_class.new(4, 4).compare_channel(image2, Magick::MeanAbsoluteErrorMetric) { |options| options.highlight_color = color }
      diff.pixel_color(0, 0)
    end
    expect(highlighted[1]).not_to eq(highlighted[0])
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(20, 20)
    expect { image.compare_channel(image_list, Magick::MeanAbsoluteErrorMetric) }.not_to raise_error
    expect { image.compare_channel(image_list, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel) }.not_to raise_error
  end
end
