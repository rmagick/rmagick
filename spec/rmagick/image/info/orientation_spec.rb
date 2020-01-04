RSpec.describe Magick::Image::Info, '#orientation' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    Magick::OrientationType.values.each do |v|
      expect { @info.orientation = v }.not_to raise_error
      expect(@info.orientation).to eq(v)
    end
    expect { @info.orientation = nil }.to raise_error(TypeError)
  end
end
