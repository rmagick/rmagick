RSpec.describe Magick::Draw, '#affine' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.affine(10.5, 12, 15, 20, 22, 25)
    expect(@draw.inspect).to eq('affine 10.5,12,15,20,22,25')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.affine('x', 12, 15, 20, 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 'x', 15, 20, 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 'x', 20, 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 15, 'x', 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 15, 20, 'x', 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 15, 20, 22, 'x') }.to raise_error(ArgumentError)
  end
end
