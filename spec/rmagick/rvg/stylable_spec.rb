# frozen_string_literal: true

require 'tmpdir'

describe Magick::RVG::Stylable do
  # Regression: a style value was dispatched straight onto Magick::Draw, whose
  # primitive builders wrapped it with Draw#enquote without escaping an embedded
  # quote (and did not quote :clip_path at all), so the value could close the MVG
  # token and inject an `image` primitive that reads an arbitrary file.
  it 'does not let a style value inject an MVG primitive' do
    Dir.mktmpdir do |dir|
      secret = File.join(dir, 'secret.png')
      Magick::Image.new(80, 80) { |options| options.background_color = 'red' }.write(secret)

      %i[fill stroke].each do |style|
        rvg = Magick::RVG.new(200, 120) do |canvas|
          canvas.background_fill = 'white'
          canvas.text(10, 30, 'hi').styles(style => %(none" image Over 0,0 80,80 "#{secret}" "))
        end

        image = begin
          rvg.draw
        rescue Magick::ImageMagickError
          nil
        end
        next if image.nil?

        drew_secret = image.export_pixels(0, 0, 200, 120, 'RGB').each_slice(3)
                           .any? { |red, green, blue| red > 50_000 && green < 15_000 && blue < 15_000 }
        expect(drew_secret).to be(false)
      end
    end
  end
end
