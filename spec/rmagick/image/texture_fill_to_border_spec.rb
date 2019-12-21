RSpec.describe Magick::Image, '#texture_fill_to_border' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    texture = Magick::Image.read('granite:').first
    expect do
      res = @img.texture_fill_to_border(@img.columns / 2, @img.rows / 2, texture)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.texture_fill_to_border(@img.columns / 2, @img.rows / 2, 'x') }.to raise_error(NoMethodError)
    expect { @img.texture_fill_to_border(@img.columns * 2, @img.rows, texture) }.to raise_error(ArgumentError)
    expect { @img.texture_fill_to_border(@img.columns, @img.rows * 2, texture) }.to raise_error(ArgumentError)

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { @img.texture_flood_fill('blue', texture, @img.columns, @img.rows, method) }.to raise_error(ArgumentError)
    end
  end
end
