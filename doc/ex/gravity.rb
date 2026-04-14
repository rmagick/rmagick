# frozen_string_literal: true

#
#   A RMagick version of Magick++/demo/gravity.cpp
#

require 'rmagick'

x = 100
y = 100

begin
  pic = Magick::ImageList.new

  lines = Magick::Draw.new
  lines.stroke '#600'
  lines.fill_opacity 0
  lines.line 300, 100, 300, 500
  lines.line 100, 300, 500, 300
  lines.rectangle 100, 100, 500, 500

  draw = Magick::Draw.new
  draw.pointsize = 30
  draw.fill = '#600'
  draw.undercolor = 'red'

  0.step(330, 30) do |angle|
    puts "angle #{angle}"
    pic.new_image(600, 600) { |info| info.background_color = 'white' }

    lines.draw pic

    draw.annotate(pic, 0, 0, x, y, 'NorthWest') do |options|
      options.gravity = Magick::NorthWestGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, 0, y, 'North') do |options|
      options.gravity = Magick::NorthGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, x, y, 'NorthEast') do |options|
      options.gravity = Magick::NorthEastGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, x, 0, 'East') do |options|
      options.gravity = Magick::EastGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, 0, 0, 'Center') do |options|
      options.gravity = Magick::CenterGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, x, y, 'SouthEast') do |options|
      options.gravity = Magick::SouthEastGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, 0, y, 'South') do |options|
      options.gravity = Magick::SouthGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, x, y, 'SouthWest') do |options|
      options.gravity = Magick::SouthWestGravity
      options.rotation = angle
    end
    draw.annotate(pic, 0, 0, x, 0, 'West') do |options|
      options.gravity = Magick::WestGravity
      options.rotation = angle
    end
  end

  puts 'Writing image "rm_gravity_out.miff"...'
  pic.delay = 20
  pic.write './rm_gravity_out.miff'
rescue StandardError
  puts "#{$ERROR_INFO} exception raised."
  exit 1
end

exit 0
