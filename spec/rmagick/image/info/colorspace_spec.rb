RSpec.describe Magick::Image::Info, '#colorspace' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    Magick::ColorspaceType.values.each do |cs|
      expect { @info.colorspace = cs }.not_to raise_error
      expect(@info.colorspace).to eq(cs)
    end
  end
end
