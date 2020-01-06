RSpec.describe Magick::Image::Info, '#gravity' do
  it 'works' do
    info = described_class.new

    Magick::GravityType.values.each do |v|
      expect { info.gravity = v }.not_to raise_error
      expect(info.gravity).to eq(v)
    end
    expect { info.gravity = nil }.not_to raise_error
  end
end
