RSpec.describe Magick::Draw, '#opacity' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.opacity(0.8)
    expect(@draw.inspect).to eq('opacity 0.8')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.opacity(0.0) }.not_to raise_error
    expect { @draw.opacity(1.0) }.not_to raise_error
    expect { @draw.opacity('0.0') }.not_to raise_error
    expect { @draw.opacity('1.0') }.not_to raise_error
    expect { @draw.opacity('20%') }.not_to raise_error

    expect { @draw.opacity(-0.01) }.to raise_error(ArgumentError)
    expect { @draw.opacity(1.01) }.to raise_error(ArgumentError)
    expect { @draw.opacity('-0.01') }.to raise_error(ArgumentError)
    expect { @draw.opacity('1.01') }.to raise_error(ArgumentError)
    expect { @draw.opacity('xxx') }.to raise_error(ArgumentError)
  end
end
