RSpec.describe Magick::Image, "#colormap" do
  it "works" do
    image = described_class.new(20, 20)

    # IndexError b/c image is DirectClass
    expect { image.colormap(0) }.to raise_error(IndexError)
    # Read PseudoClass image
    pc_image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect { pc_image.colormap(0) }.not_to raise_error
    ncolors = pc_image.colors
    expect { pc_image.colormap(ncolors + 1) }.to raise_error(IndexError)
    expect { pc_image.colormap(-1) }.to raise_error(IndexError)
    expect { pc_image.colormap(ncolors - 1) }.not_to raise_error
    result = pc_image.colormap(0)
    expect(result).to be_instance_of(String)

    # test 'set' operation
    old_color = pc_image.colormap(0)
    result = pc_image.colormap(0, 'red')
    expect(result).to eq(old_color)
    result = pc_image.colormap(0)
    expect(result).to eq('red')

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { pc_image.colormap(0, pixel) }.not_to raise_error
    expect { pc_image.colormap }.to raise_error(ArgumentError)
    expect { pc_image.colormap(0, pixel, Magick::BlackChannel) }.to raise_error(ArgumentError)
    expect { pc_image.colormap(0, [2]) }.to raise_error(TypeError)
    pc_image.freeze
    expect { pc_image.colormap(0, 'red') }.to raise_error(FreezeError)
  end
end
