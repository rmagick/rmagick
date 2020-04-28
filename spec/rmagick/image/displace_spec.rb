RSpec.describe Magick::Image, '#displace' do
  it 'works' do
    image = described_class.new(20, 20)
    image2 = described_class.new(20, 20) { self.background_color = 'black' }

    expect { image.displace(image2, 25) }.not_to raise_error
    result = image.displace(image2, 25)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)
    expect { image.displace(image2, 25, 25) }.not_to raise_error
    expect { image.displace(image2, 25, 25, 10) }.not_to raise_error
    expect { image.displace(image2, 25, 25, 10, 10) }.not_to raise_error
    expect { image.displace(image2, 25, 25, Magick::CenterGravity) }.not_to raise_error
    expect { image.displace(image2, 25, 25, Magick::CenterGravity, 10) }.not_to raise_error
    expect { image.displace(image2, 25, 25, Magick::CenterGravity, 10, 10) }.not_to raise_error
    expect { image.displace }.to raise_error(ArgumentError)
    expect { image.displace(image2, 'x') }.to raise_error(TypeError)
    expect { image.displace(image2, 25, []) }.to raise_error(TypeError)
    expect { image.displace(image2, 25, 25, 'x') }.to raise_error(TypeError)
    expect { image.displace(image2, 25, 25, Magick::CenterGravity, 'x') }.to raise_error(TypeError)
    expect { image.displace(image2, 25, 25, Magick::CenterGravity, 10, []) }.to raise_error(TypeError)

    image2.destroy!
    expect { image.displace(image2, 25, 25) }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.displace(image_list, 25) }.not_to raise_error
    expect { image.displace(image_list, 25, 25) }.not_to raise_error
    expect { image.displace(image_list, 25, 25, 10) }.not_to raise_error
    expect { image.displace(image_list, 25, 25, 10, 10) }.not_to raise_error
    expect { image.displace(image_list, 25, 25, Magick::CenterGravity) }.not_to raise_error
    expect { image.displace(image_list, 25, 25, Magick::CenterGravity, 10) }.not_to raise_error
    expect { image.displace(image_list, 25, 25, Magick::CenterGravity, 10, 10) }.not_to raise_error
  end
end
