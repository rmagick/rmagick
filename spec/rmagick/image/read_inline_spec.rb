RSpec.describe Magick::Image, "#read_inline" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    blob = img.to_blob
    encoded = [blob].pack('m*')
    res = Magick::Image.read_inline(encoded)
    expect(res).to be_instance_of(Array)
    expect(res[0]).to be_instance_of(Magick::Image)
    expect(res[0]).to eq(img)
    expect { Magick::Image.read(nil) }.to raise_error(ArgumentError)
    expect { Magick::Image.read("") }.to raise_error(ArgumentError)
  end
end
