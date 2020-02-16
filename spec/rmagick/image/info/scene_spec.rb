RSpec.describe Magick::Image::Info, '#scene' do
  it 'works' do
    info = described_class.new

    expect { info.scene = 123 }.not_to raise_error
    expect(info.scene).to eq(123)
    expect { info.scene = 'xxx' }.to raise_error(TypeError)
  end
end
