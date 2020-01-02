RSpec.describe Magick::Image, "#change_geometry" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect { @img.change_geometry('sss') }.to raise_error(ArgumentError)
    expect { @img.change_geometry('100x100') }.to raise_error(LocalJumpError)
    expect do
      res = @img.change_geometry('100x100') { 1 }
      expect(res).to eq(1)
    end.not_to raise_error
    expect { @img.change_geometry([]) }.to raise_error(ArgumentError)
  end
end
