RSpec.describe Magick::Image, '#geometry' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.geometry }.not_to raise_error
    expect(@img.geometry).to be(nil)
    expect { @img.geometry = nil }.not_to raise_error
    expect { @img.geometry = '90x90' }.not_to raise_error
    expect(@img.geometry).to eq('90x90')
    expect { @img.geometry = Magick::Geometry.new(100, 80) }.not_to raise_error
    expect(@img.geometry).to eq('100x80')
    expect { @img.geometry = [] }.to raise_error(TypeError)
  end
end
