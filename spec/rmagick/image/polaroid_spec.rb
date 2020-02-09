RSpec.describe Magick::Image, '#polaroid' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect { @img.polaroid }.not_to raise_error
    expect { @img.polaroid(5) }.not_to raise_error
    expect(@img.polaroid).to be_instance_of(described_class)
    expect { @img.polaroid('x') }.to raise_error(TypeError)
    expect { @img.polaroid(5, 'x') }.to raise_error(ArgumentError)
  end
end
