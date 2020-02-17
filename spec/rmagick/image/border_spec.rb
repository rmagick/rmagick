RSpec.describe Magick::Image, "#border" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.border(2, 2, 'red') }.not_to raise_error
    expect { image.border!(2, 2, 'red') }.not_to raise_error
    res = image.border(2, 2, 'red')
    expect(res).to be_instance_of(described_class)
    image.freeze
    expect { image.border!(2, 2, 'red') }.to raise_error(FreezeError)
  end
end
