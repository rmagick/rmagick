# frozen_string_literal: true

# Marks the rest of an example pending on the ImageMagick versions that have a
# known bug. RSpec fails a pending example that passes, so CI reports when a
# fixed version is out.
module ImageMagickBugs
  # ImageMagick 6.9.13-60 and later write the first pixel of each GIF frame as
  # colormap index 1 unless its index is 0, because the encoder masks it with
  # `&& 0xff` instead of `& 0xff`.
  # https://github.com/ImageMagick/ImageMagick6/issues/490
  #
  # Remove this method and its calls once CI and the ImageMagick 6 devcontainer
  # use a release with the fix. RSpec then fails the pending examples because
  # they pass.
  def pending_on_im6_gif_bug
    version = Magick::Magick_version.split[1]
    numbers = version.scan(/\d+/).map { |number| Integer(number, 10) }
    return if numbers.first != 6 || (numbers <=> [6, 9, 13, 60]).negative?

    pending "ImageMagick #{version} writes a wrong color for the first pixel of a GIF"
  end
end
