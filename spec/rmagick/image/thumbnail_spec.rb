RSpec.describe Magick::Image, '#thumbnail' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.thumbnail(10, 10)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.thumbnail(2) }.not_to raise_error
    expect { @img.thumbnail }.to raise_error(ArgumentError)
    expect { @img.thumbnail(-1.0) }.to raise_error(ArgumentError)
    expect { @img.thumbnail(0, 25) }.to raise_error(ArgumentError)
    expect { @img.thumbnail(25, 0) }.to raise_error(ArgumentError)
    expect { @img.thumbnail(25, 25, 25) }.to raise_error(ArgumentError)
    expect { @img.thumbnail('x') }.to raise_error(TypeError)
    expect { @img.thumbnail(10, 'x') }.to raise_error(TypeError)

    girl = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    new_img = girl.thumbnail(200, 200)
    expect(new_img.columns).to eq(160)
    expect(new_img.rows).to eq(200)

    new_img = girl.thumbnail(2)
    expect(new_img.columns).to eq(400)
    expect(new_img.rows).to eq(500)
  end
end
