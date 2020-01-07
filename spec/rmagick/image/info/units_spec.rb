RSpec.describe Magick::Image::Info, '#units' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    Magick::ResolutionType.values.each do |v|
      expect { @info.units = v }.not_to raise_error
      expect(@info.units).to eq(v)
    end
  end
end
