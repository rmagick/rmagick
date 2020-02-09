RSpec.describe Magick::Image::Info, '#dispose' do
  before do
    @info = described_class.new
  end

  it 'works' do
    Magick::DisposeType.values.each do |v|
      expect { @info.dispose = v }.not_to raise_error
      expect(@info.dispose).to eq(v)
    end
    expect { @info.dispose = nil }.not_to raise_error
  end
end
