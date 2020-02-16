RSpec.describe Magick::Image, '#vignette' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.vignette
      expect(res).to be_instance_of(described_class)
      expect(img).not_to be(res)
    end.not_to raise_error
    expect { img.vignette(0) }.not_to raise_error
    expect { img.vignette(0, 0) }.not_to raise_error
    expect { img.vignette(0, 0, 0) }.not_to raise_error
    expect { img.vignette(0, 0, 0, 1) }.not_to raise_error
    # too many arguments
    expect { img.vignette(0, 0, 0, 1, 1) }.to raise_error(ArgumentError)
  end
end
