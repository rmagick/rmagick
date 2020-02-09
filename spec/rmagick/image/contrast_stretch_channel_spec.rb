RSpec.describe Magick::Image, '#contrast_stretch_channel' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.contrast_stretch_channel(25)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50) }.not_to raise_error
    expect { @img.contrast_stretch_channel('10%') }.not_to raise_error
    expect { @img.contrast_stretch_channel('10%', '50%') }.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50, Magick::RedChannel) }.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50, 'x') }.to raise_error(TypeError)
    expect { @img.contrast_stretch_channel }.to raise_error(ArgumentError)
    expect { @img.contrast_stretch_channel('x') }.to raise_error(ArgumentError)
    expect { @img.contrast_stretch_channel(25, 'x') }.to raise_error(ArgumentError)
  end
end
