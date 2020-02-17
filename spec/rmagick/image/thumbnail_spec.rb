RSpec.describe Magick::Image, '#thumbnail' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.thumbnail(10, 10)
    expect(res).to be_instance_of(described_class)

    expect { image.thumbnail(2) }.not_to raise_error
    expect { image.thumbnail }.to raise_error(ArgumentError)
    expect { image.thumbnail(-1.0) }.to raise_error(ArgumentError)
    expect { image.thumbnail(0, 25) }.to raise_error(ArgumentError)
    expect { image.thumbnail(25, 0) }.to raise_error(ArgumentError)
    expect { image.thumbnail(25, 25, 25) }.to raise_error(ArgumentError)
    expect { image.thumbnail('x') }.to raise_error(TypeError)
    expect { image.thumbnail(10, 'x') }.to raise_error(TypeError)

    girl = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    new_image = girl.thumbnail(200, 200)
    expect(new_image.columns).to eq(160)
    expect(new_image.rows).to eq(200)

    new_image = girl.thumbnail(2)
    expect(new_image.columns).to eq(400)
    expect(new_image.rows).to eq(500)
  end
end
