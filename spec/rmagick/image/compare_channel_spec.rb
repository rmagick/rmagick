RSpec.describe Magick::Image, "#compare_channel" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first

    Magick::MetricType.values do |metric|
      expect { img1.compare_channel(img2, metric) }.not_to raise_error
    end
    expect { img1.compare_channel(img2, 2) }.to raise_error(TypeError)
    expect { img1.compare_channel }.to raise_error(ArgumentError)

    ilist = Magick::ImageList.new
    ilist << img2
    expect { img1.compare_channel(ilist, Magick::MeanAbsoluteErrorMetric) }.not_to raise_error

    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel) }.not_to raise_error
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, 2) }.to raise_error(TypeError)
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel, 2) }.to raise_error(TypeError)

    res = img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric)
    expect(res).to be_instance_of(Array)
    expect(res[0]).to be_instance_of(Magick::Image)
    expect(res[1]).to be_instance_of(Float)

    img2.destroy!
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric) }.to raise_error(Magick::DestroyedImageError)
  end
end
