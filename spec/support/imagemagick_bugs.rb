# frozen_string_literal: true

# Marks the rest of an example pending on the ImageMagick versions that have a
# known bug. Once a fixed version passes the example, RSpec reports it, so the
# guard can be narrowed down.
module ImageMagickBugs
  # ImageMagick 6.9.13-60 and later write the first pixel of a GIF with color
  # index 0 or 1, because the encoder masks it with `&& 0xff` instead of `& 0xff`.
  # https://github.com/ImageMagick/ImageMagick6/commit/d267cf0c290e3364316dd7f5710db5449539a240
  def pending_on_im6_gif_bug
    version = Magick::Magick_version.split[1]
    numbers = version.scan(/\d+/).map { |number| Integer(number, 10) }
    return if numbers.first != 6 || (numbers <=> [6, 9, 13, 60]).negative?

    pending "ImageMagick #{version} writes a wrong color for the first pixel of a GIF" # rubocop:disable RSpec/Pending
  end
end
