RSpec.describe Magick::Image, "#read_inline" do
  it "works" do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    blob = image.to_blob
    encoded = [blob].pack('m*')
    result = described_class.read_inline(encoded)
    expect(result).to be_instance_of(Array)
    expect(result[0]).to be_instance_of(described_class)
    expect(result[0]).to eq(image)
    expect { described_class.read(nil) }.to raise_error(ArgumentError)
    expect { described_class.read("") }.to raise_error(ArgumentError)
  end
end
