RSpec.describe Magick::Image, "#border" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect { @img.border(2, 2, 'red') }.not_to raise_error
    expect { @img.border!(2, 2, 'red') }.not_to raise_error
    res = @img.border(2, 2, 'red')
    expect(res).to be_instance_of(Magick::Image)
    @img.freeze
    expect { @img.border!(2, 2, 'red') }.to raise_error(FreezeError)
  end
end
