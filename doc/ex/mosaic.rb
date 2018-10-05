#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the mosaic method

a = Magick::ImageList.new

letter = 'A'
26.times do
  # 'M' is not the same size as the other letters.
  a.read('images/Button_' + letter + '.gif') if letter != 'M'
  letter.succ!
end

# Make a copy of "a" with all the images quarter-sized
b = Magick::ImageList.new
page = Magick::Rectangle.new(0, 0, 0, 0)
a.scene = 0
5.times do |i|
  5.times do |j|
    b << a.scale(0.25)
    page.x = j * b.columns
    page.y = i * b.rows
    b.page = page
    begin
      (a.scene += 1)
    rescue StandardError
      a.scene = 0
    end
  end
end

# Make a 5x5 mosaic
mosaic = b.mosaic
mosaic.write('mosaic.gif')
# mosaic.display
exit
