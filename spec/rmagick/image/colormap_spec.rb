RSpec.describe Magick::Image, "#colormap" do
  it "works" do
    img = described_class.new(20, 20)

    # IndexError b/c img is DirectClass
    expect { img.colormap(0) }.to raise_error(IndexError)
    # Read PseudoClass image
    pc_img = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect { pc_img.colormap(0) }.not_to raise_error
    ncolors = pc_img.colors
    expect { pc_img.colormap(ncolors + 1) }.to raise_error(IndexError)
    expect { pc_img.colormap(-1) }.to raise_error(IndexError)
    expect { pc_img.colormap(ncolors - 1) }.not_to raise_error
    res = pc_img.colormap(0)
    expect(res).to be_instance_of(String)

    # test 'set' operation
    old_color = pc_img.colormap(0)
    res = pc_img.colormap(0, 'red')
    expect(res).to eq(old_color)
    res = pc_img.colormap(0)
    expect(res).to eq('red')

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { pc_img.colormap(0, pixel) }.not_to raise_error
    expect { pc_img.colormap }.to raise_error(ArgumentError)
    expect { pc_img.colormap(0, pixel, Magick::BlackChannel) }.to raise_error(ArgumentError)
    expect { pc_img.colormap(0, [2]) }.to raise_error(TypeError)
    pc_img.freeze
    expect { pc_img.colormap(0, 'red') }.to raise_error(FreezeError)
  end
end
