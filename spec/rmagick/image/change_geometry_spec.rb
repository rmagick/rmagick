RSpec.describe Magick::Image, "#change_geometry" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.change_geometry('sss') }.to raise_error(ArgumentError)
    expect { image.change_geometry('100x100') }.to raise_error(LocalJumpError)

    result = image.change_geometry('100x100') { 1 }
    expect(result).to eq(1)

    expect { image.change_geometry([]) }.to raise_error(ArgumentError)
  end
end
