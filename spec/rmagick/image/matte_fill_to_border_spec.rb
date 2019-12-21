RSpec.describe Magick::Image, '#matte_fill_to_border' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.matte_fill_to_border(@img.columns / 2, @img.rows / 2)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.matte_fill_to_border(@img.columns, @img.rows) }.not_to raise_error
    expect { @img.matte_fill_to_border(@img.columns + 1, @img.rows) }.to raise_error(ArgumentError)
    expect { @img.matte_fill_to_border(@img.columns, @img.rows + 1) }.to raise_error(ArgumentError)
  end
end
