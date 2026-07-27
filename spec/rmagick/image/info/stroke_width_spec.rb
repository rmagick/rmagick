# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#stroke_width' do
  it 'works' do
    info = described_class.new

    expect { info.stroke_width = 10 }.not_to raise_error
    expect(info.stroke_width).to eq(10)
    expect { info.stroke_width = 5.25 }.not_to raise_error
    expect(info.stroke_width).to eq(5.25)
    expect { info.stroke_width = nil }.not_to raise_error
    expect(info.stroke_width).to be(nil)
    expect { info.stroke_width = 'xxx' }.to raise_error(TypeError)
  end

  it 'accepts a value whose formatted form is longer than the internal buffer' do
    info = described_class.new

    # "%-10.2f" of these needs more than the 50-byte buffer, so snprintf
    # returns a length greater than the buffer size.
    [1e47, 1e300, Float::MAX].each do |value|
      expect { info.stroke_width = value }.not_to raise_error
    end
  end
end
