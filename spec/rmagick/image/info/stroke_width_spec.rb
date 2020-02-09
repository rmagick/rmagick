RSpec.describe Magick::Image::Info, '#stroke_width' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.stroke_width = 10 }.not_to raise_error
    expect(@info.stroke_width).to eq(10)
    expect { @info.stroke_width = 5.25 }.not_to raise_error
    expect(@info.stroke_width).to eq(5.25)
    expect { @info.stroke_width = nil }.not_to raise_error
    expect(@info.stroke_width).to be(nil)
    expect { @info.stroke_width = 'xxx' }.to raise_error(TypeError)
  end
end
