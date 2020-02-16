RSpec.describe Magick::Image, '#scene' do
  it 'works' do
    img1 = described_class.new(100, 100)
    ilist = Magick::ImageList.new
    ilist << img1
    img2 = img1.copy
    ilist << img2
    ilist.write('temp.gif')
    FileUtils.rm('temp.gif')

    expect { img2.scene }.not_to raise_error
    expect(img1.scene).to eq(0)
    expect(img2.scene).to eq(1)
    expect { img2.scene = 2 }.to raise_error(NoMethodError)
  end
end
