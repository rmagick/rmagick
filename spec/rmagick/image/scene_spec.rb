RSpec.describe Magick::Image, '#scene' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    ilist = Magick::ImageList.new
    ilist << @img
    img2 = @img.copy
    ilist << img2
    ilist.write('temp.gif')
    FileUtils.rm('temp.gif')

    expect { img2.scene }.not_to raise_error
    expect(@img.scene).to eq(0)
    expect(img2.scene).to eq(1)
    expect { img2.scene = 2 }.to raise_error(NoMethodError)
  end
end
