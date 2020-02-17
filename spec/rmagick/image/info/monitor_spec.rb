RSpec.describe Magick::Image::Info, '#monitor' do
  it 'works' do
    info = described_class.new

    expect { info.monitor = -> {} }.not_to raise_error
    monitor = proc do |mth, q, s|
      expect(mth).to eq('resize!')
      expect(q).to be_kind_of(Integer)
      expect(s).to be_kind_of(Integer)
      GC.start
      true
    end
    image = Magick::Image.new(2000, 2000) { self.monitor = monitor }
    image.resize!(20, 20)
    image.monitor = nil

    expect { info.monitor = nil }.not_to raise_error
  end
end
