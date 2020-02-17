RSpec.describe Magick::Image, '#difference' do
  it 'works' do
    img1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

    res = img1.difference(img2)
    expect(res).to be_instance_of(Array)
    expect(res.length).to eq(3)
    expect(res[0]).to be_instance_of(Float)
    expect(res[1]).to be_instance_of(Float)
    expect(res[2]).to be_instance_of(Float)

    expect { img1.difference(2) }.to raise_error(NoMethodError)
    img2.destroy!
    expect { img1.difference(img2) }.to raise_error(Magick::DestroyedImageError)
  end
end
