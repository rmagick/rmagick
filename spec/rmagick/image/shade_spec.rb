RSpec.describe Magick::Image, '#shade' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.shade
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { @img.shade(true) }.not_to raise_error
    expect { @img.shade(true, 30) }.not_to raise_error
    expect { @img.shade(true, 30, 30) }.not_to raise_error
    expect { @img.shade(true, 30, 30, 2) }.to raise_error(ArgumentError)
    expect { @img.shade(true, 'x') }.to raise_error(TypeError)
    expect { @img.shade(true, 30, 'x') }.to raise_error(TypeError)
  end
end
