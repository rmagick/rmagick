RSpec.describe Magick::Image, '#level2' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    img1 = @img.level(10, 2, 200)
    img2 = @img.level(10, 200, 2)
    expect(img1).to eq(img2)

    # Ensure that level2 uses new arg order
    img1 = @img.level2(10, 200, 2)
    expect(img1).to eq(img2)

    expect { @img.level2 }.not_to raise_error
    expect { @img.level2(10) }.not_to raise_error
    expect { @img.level2(10, 10) }.not_to raise_error
    expect { @img.level2(10, 10, 10) }.not_to raise_error
    expect { @img.level2(10, 10, 10, 10) }.to raise_error(ArgumentError)
  end
end
