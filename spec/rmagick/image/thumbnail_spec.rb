RSpec.describe Magick::Image, '#thumbnail' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.thumbnail(10, 10)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { img.thumbnail(2) }.not_to raise_error
    expect { img.thumbnail }.to raise_error(ArgumentError)
    expect { img.thumbnail(-1.0) }.to raise_error(ArgumentError)
    expect { img.thumbnail(0, 25) }.to raise_error(ArgumentError)
    expect { img.thumbnail(25, 0) }.to raise_error(ArgumentError)
    expect { img.thumbnail(25, 25, 25) }.to raise_error(ArgumentError)
    expect { img.thumbnail('x') }.to raise_error(TypeError)
    expect { img.thumbnail(10, 'x') }.to raise_error(TypeError)

    girl = described_class.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    new_img = girl.thumbnail(200, 200)
    expect(new_img.columns).to eq(160)
    expect(new_img.rows).to eq(200)

    new_img = girl.thumbnail(2)
    expect(new_img.columns).to eq(400)
    expect(new_img.rows).to eq(500)
  end
end
