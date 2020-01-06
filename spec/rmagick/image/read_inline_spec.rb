RSpec.describe Magick::Image, "#read_inline" do
  it "works" do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    blob = img.to_blob
    encoded = [blob].pack('m*')
    res = described_class.read_inline(encoded)
    expect(res).to be_instance_of(Array)
    expect(res[0]).to be_instance_of(described_class)
    expect(res[0]).to eq(img)
    expect { described_class.read(nil) }.to raise_error(ArgumentError)
    expect { described_class.read("") }.to raise_error(ArgumentError)
  end
end
