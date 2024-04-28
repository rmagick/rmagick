RSpec.describe Magick::Image::Info, '#transparent_color' do
  it 'works' do
    info = described_class.new

    expect { info.transparent_color = 'white' }.not_to raise_error
    expected = value_by_version(
      "6.8": "#FFFFFFFFFFFF",
      "6.9": "#FFFFFFFFFFFFFFFF",
      "7.0": "#FFFFFFFFFFFFFFFF",
      "7.1": "#FFFFFFFFFFFFFFFF"
    )
    expect(info.transparent_color).to eq(expected)
    expect { info.transparent_color = nil }.to raise_error(TypeError)
  end
end
