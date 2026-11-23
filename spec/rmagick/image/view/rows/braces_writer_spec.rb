# frozen_string_literal: true

RSpec.describe Magick::Image::View::Rows, '#[]=' do
  it 'assigns only the pixels inside the view' do
    image = Magick::Image.new(10, 10)
    image.view(0, 0, 10, 10) { |view| view[0][8, 5] = 'red' }

    expect(image.pixel_color(7, 0)).to eq(Magick::Pixel.from_color('white'))
    expect(image.pixel_color(8, 0)).to eq(Magick::Pixel.from_color('red'))
    expect(image.pixel_color(9, 0)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'counts negative values in an array from the end' do
    image = Magick::Image.new(10, 10)
    image.view(0, 0, 10, 10) do |view|
      view[[2]][[-3]] = 'red'
      view[[-2]][[3]] = 'blue'
    end

    expect(image.pixel_color(7, 2)).to eq(Magick::Pixel.from_color('red'))
    expect(image.pixel_color(7, 1)).to eq(Magick::Pixel.from_color('white'))
    expect(image.pixel_color(3, 8)).to eq(Magick::Pixel.from_color('blue'))
  end

  it 'does not write any pixel when an index is outside the view' do
    image = Magick::Image.new(10, 10)
    image.view(0, 0, 10, 10) do |view|
      view[5][5] = 'blue'
      expect { view[0][[8, 9, 10]] = 'red' }.to raise_error(IndexError)
    end

    expect(image.pixel_color(5, 5)).to eq(Magick::Pixel.from_color('blue'))
    expect(image.pixel_color(8, 0)).to eq(Magick::Pixel.from_color('white'))
  end
end
