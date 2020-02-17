RSpec.describe Magick::Image, "#change_geometry" do
  it "works" do
    img = described_class.new(20, 20)

    expect { img.change_geometry('sss') }.to raise_error(ArgumentError)
    expect { img.change_geometry('100x100') }.to raise_error(LocalJumpError)

    res = img.change_geometry('100x100') { 1 }
    expect(res).to eq(1)

    expect { img.change_geometry([]) }.to raise_error(ArgumentError)
  end
end
