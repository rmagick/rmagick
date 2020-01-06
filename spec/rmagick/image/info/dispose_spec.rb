RSpec.describe Magick::Image::Info, '#dispose' do
  it 'works' do
    info = described_class.new

    Magick::DisposeType.values.each do |v|
      expect { info.dispose = v }.not_to raise_error
      expect(info.dispose).to eq(v)
    end
    expect { info.dispose = nil }.not_to raise_error
  end
end
