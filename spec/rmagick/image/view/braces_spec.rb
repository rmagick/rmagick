# frozen_string_literal: true

RSpec.describe Magick::Image::View, '#[]' do
  it 'clips start and length to the end of the view' do
    view = Magick::Image.new(10, 10).view(0, 0, 10, 10)

    expect(view[2, 9][].size).to eq(80)
    expect(view[0, 20][].size).to eq(100)
    expect(view[-3, 5][].size).to eq(30)
    expect(view[10, 1][].size).to eq(0)
    expect(view[0][2, 9].size).to eq(8)
    expect(view[0][0, 20].size).to eq(10)
    expect(view[0][-3, 5].size).to eq(3)
    expect(view[0][10, 1].size).to eq(0)
  end

  it 'assigns only the pixels inside the view' do
    image = Magick::Image.new(10, 10)
    image.view(0, 0, 10, 10) { |view| view[0][8, 5] = 'red' }

    expect(image.pixel_color(7, 0)).to eq(Magick::Pixel.from_color('white'))
    expect(image.pixel_color(8, 0)).to eq(Magick::Pixel.from_color('red'))
    expect(image.pixel_color(9, 0)).to eq(Magick::Pixel.from_color('red'))
  end
end
