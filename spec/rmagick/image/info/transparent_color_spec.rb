# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#transparent_color' do
  it 'works' do
    info = described_class.new
    info.depth = 16

    expect { info.transparent_color = 'white' }.not_to raise_error
    expect(info.transparent_color).to eq('#FFFFFFFFFFFFFFFF')
    expect { info.transparent_color = nil }.to raise_error(TypeError)

    info = described_class.new
    info.depth = 8

    expect { info.transparent_color = 'white' }.not_to raise_error
    expect(info.transparent_color).to eq('#FFFFFFFF')
  end
end
