RSpec.describe Magick::Image, '#rotate' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.rotate(45)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.rotate(-45) }.not_to raise_error

    img = Magick::Image.new(100, 50)
    expect do
      res = img.rotate(90, '>')
      expect(res).to be_instance_of(Magick::Image)
      expect(res.columns).to eq(50)
      expect(res.rows).to eq(100)
    end.not_to raise_error
    expect do
      res = img.rotate(90, '<')
      expect(res).to be(nil)
    end.not_to raise_error
    expect { img.rotate(90, 't') }.to raise_error(ArgumentError)
    expect { img.rotate(90, []) }.to raise_error(TypeError)
  end
end
