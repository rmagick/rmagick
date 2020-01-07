RSpec.describe Magick::Image::Info, '#monitor' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.monitor = -> {} }.not_to raise_error
    monitor = proc do |mth, q, s|
      expect(mth).to eq('resize!')
      expect(q).to be_kind_of(Integer)
      expect(s).to be_kind_of(Integer)
      GC.start
      true
    end
    img = Magick::Image.new(2000, 2000) { self.monitor = monitor }
    img.resize!(20, 20)
    img.monitor = nil

    expect { @info.monitor = nil }.not_to raise_error
  end
end
