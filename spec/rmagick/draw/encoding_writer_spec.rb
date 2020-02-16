RSpec.describe Magick::Draw, '#encoding=' do
  it 'works' do
    draw = described_class.new

    expect { draw.encoding = 'AdobeCustom' }.not_to raise_error
    expect { draw.encoding = 2 }.to raise_error(TypeError)
  end
end
