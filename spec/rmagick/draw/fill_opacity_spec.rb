RSpec.describe Magick::Draw, '#fill_opacity' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = described_class.new
    draw.fill_opacity(0.5)
    expect(draw.inspect).to eq('fill-opacity 0.5')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(@img) }.not_to raise_error

    draw = described_class.new
    draw.fill_opacity('50%')
    expect(draw.inspect).to eq('fill-opacity 50%')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.fill_opacity(0.0) }.not_to raise_error
    expect { @draw.fill_opacity(1.0) }.not_to raise_error
    expect { @draw.fill_opacity('0.0') }.not_to raise_error
    expect { @draw.fill_opacity('1.0') }.not_to raise_error
    expect { @draw.fill_opacity('20%') }.not_to raise_error

    expect { @draw.fill_opacity(-0.01) }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity(1.01) }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity('-0.01') }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity('1.01') }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity('xxx') }.to raise_error(ArgumentError)
  end
end
