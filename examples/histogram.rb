# frozen_string_literal: true

# This routine needs the color_histogram method from ImageMagick 6.0.0.
# Specify an image filename as an argument.

require 'rmagick'

class PixelColumn < Array
  def initialize(size)
    super
    fill { Magick::Pixel.new }
  end

  def reset(bg)
    each { |pixel| pixel.reset(bg) }
  end
end

module Magick
  class Pixel
    def reset(bg)
      self.red = bg.red
      self.green = bg.green
      self.blue = bg.blue
      self.alpha = bg.alpha
    end
  end

  class Image
    HISTOGRAM_COLS = 256
    private_constant :HISTOGRAM_COLS
    HISTOGRAM_ROWS = 200
    private_constant :HISTOGRAM_ROWS
    MAX_QUANTUM = 255
    private_constant :MAX_QUANTUM
    AIR_FACTOR = 1.025
    private_constant :AIR_FACTOR

    private

    # The alpha frequencies are shown as white dots.
    def alpha_hist(freqs, scale, fg, bg)
      histogram = Image.new(HISTOGRAM_COLS, HISTOGRAM_ROWS) do |options|
        options.background_color = bg
        options.border_color = fg
      end

      gc = Draw.new
      gc.affine(1, 0, 0, -scale, 0, HISTOGRAM_ROWS)
      gc.fill('white')

      HISTOGRAM_COLS.times do |x|
        gc.point(x, freqs[x])
      end

      gc.draw(histogram)
      histogram['Label'] = 'Alpha'

      histogram
    end

    def channel_histograms(red, green, blue, int, scale, fg, bg)
      rgb_histogram = Image.new(HISTOGRAM_COLS, HISTOGRAM_ROWS) do |options|
        options.background_color = bg
        options.border_color = fg
      end
      rgb_histogram['Label'] = 'RGB'
      red_histogram = rgb_histogram.copy
      red_histogram['Label'] = 'Red'
      green_histogram = rgb_histogram.copy
      green_histogram['Label'] = 'Green'
      blue_histogram = rgb_histogram.copy
      blue_histogram['Label'] = 'Blue'
      int_histogram = rgb_histogram.copy
      int_histogram['Label'] = 'Intensity'
      int_histogram.alpha(Magick::ActivateAlphaChannel)

      rgb_column   = PixelColumn.new(HISTOGRAM_ROWS)
      red_column   = PixelColumn.new(HISTOGRAM_ROWS)
      green_column = PixelColumn.new(HISTOGRAM_ROWS)
      blue_column  = PixelColumn.new(HISTOGRAM_ROWS)
      int_column   = PixelColumn.new(HISTOGRAM_ROWS)

      HISTOGRAM_COLS.times do |x|
        HISTOGRAM_ROWS.times do |y|
          yf = Float(y)
          if yf >= HISTOGRAM_ROWS - (red[x] * scale)
            red_column[y].red = QuantumRange
            red_column[y].green = 0
            red_column[y].blue = 0
            rgb_column[y].red = QuantumRange
          end
          if yf >= HISTOGRAM_ROWS - (green[x] * scale)
            green_column[y].green = QuantumRange
            green_column[y].red = 0
            green_column[y].blue = 0
            rgb_column[y].green = QuantumRange
          end
          if yf >= HISTOGRAM_ROWS - (blue[x] * scale)
            blue_column[y].blue = QuantumRange
            blue_column[y].red = 0
            blue_column[y].green = 0
            rgb_column[y].blue = QuantumRange
          end
          int_column[y].alpha = TransparentAlpha if yf >= HISTOGRAM_ROWS - (int[x] * scale)
        end

        rgb_histogram.store_pixels(x, 0, 1, HISTOGRAM_ROWS, rgb_column)
        red_histogram.store_pixels(x, 0, 1, HISTOGRAM_ROWS, red_column)
        green_histogram.store_pixels(x, 0, 1, HISTOGRAM_ROWS, green_column)
        blue_histogram.store_pixels(x, 0, 1, HISTOGRAM_ROWS, blue_column)
        int_histogram.store_pixels(x, 0, 1, HISTOGRAM_ROWS, int_column)
        rgb_column.reset(bg)
        red_column.reset(bg)
        green_column.reset(bg)
        blue_column.reset(bg)
        int_column.reset(bg)
      end

      [red_histogram, green_histogram, blue_histogram, rgb_histogram, int_histogram]
    end

    # Make the color histogram. Quantize the image to 256 colors if necessary.
    def color_hist(fg, bg)
      img = number_colors > 256 ? quantize(256) : self

      hist = img.color_histogram
      pixels = hist.keys.sort_by { |pixel| hist[pixel] }
      scale = HISTOGRAM_ROWS / (hist.values.max * AIR_FACTOR)

      histogram = Image.new(HISTOGRAM_COLS, HISTOGRAM_ROWS) do |options|
        options.background_color = bg
        options.border_color = fg
      end

      x = 0
      pixels.each do |pixel|
        column = Array.new(HISTOGRAM_ROWS).fill { Pixel.new }
        HISTOGRAM_ROWS.times do |y|
          column[y] = pixel if y >= HISTOGRAM_ROWS - (hist[pixel] * scale)
        end
        histogram.store_pixels(x, 0, 1, HISTOGRAM_ROWS, column)
        x = x.succ
      end

      histogram['Label'] = 'Color Frequency'
      histogram
    end

    # Use AnnotateImage to write the stats.
    def info_text(fg, bg)
      klass = class_type == DirectClass ? 'DirectClass' : 'PsuedoClass'

      text = <<~END_TEXT
        Format: #{format}
        Geometry: #{columns}x#{rows}
        Class: #{klass}
        Depth: #{depth} bits-per-pixel component
        Colors: #{number_colors}
      END_TEXT

      info = Image.new(HISTOGRAM_COLS, HISTOGRAM_ROWS) do |options|
        options.background_color = bg
        options.border_color = fg
      end

      gc = Draw.new

      gc.annotate(info, 0, 0, 0, 0, text) do |options|
        options.stroke = 'transparent'
        options.fill = fg
        options.gravity = CenterGravity
      end
      info['Label'] = 'Info'

      info
    end

    def intensity_hist(int_histogram)
      gradient = (Image.read('gradient:#ffff80-#ff9000') { |options| options.size = "#{HISTOGRAM_COLS}x#{HISTOGRAM_ROWS}" }).first
      int_histogram = gradient.composite(int_histogram, CenterGravity, OverCompositeOp)

      int_histogram['Label'] = 'Intensity'

      int_histogram
    end

    # Returns a value between 0 and MAX_QUANTUM. Same as the PixelIntensity macro.
    def pixel_intensity(pixel)
      (306 * (pixel.red & MAX_QUANTUM) + 601 * (pixel.green & MAX_QUANTUM) + 117 * (pixel.blue & MAX_QUANTUM)) / 1024
    end

    public

    # Create the histogram montage.
    def histogram(fg = 'white', bg = 'black')
      red   = Array.new(HISTOGRAM_COLS, 0)
      green = Array.new(HISTOGRAM_COLS, 0)
      blue  = Array.new(HISTOGRAM_COLS, 0)
      alpha = Array.new(HISTOGRAM_COLS, 0)
      int   = Array.new(HISTOGRAM_COLS, 0)

      rows.times do |row|
        pixels = get_pixels(0, row, columns, 1)
        pixels.each do |pixel|
          red[pixel.red & MAX_QUANTUM] += 1
          green[pixel.green & MAX_QUANTUM] += 1
          blue[pixel.blue & MAX_QUANTUM] += 1

          # Only count opacity channel if some pixels are not opaque.
          alpha[pixel.opacity & MAX_QUANTUM] += 1 unless opaque?
          v = pixel_intensity(pixel)
          int[v] += 1
        end
      end

      # Scale to chart size. When computing the scale, add some "air" between
      # the max frequency and the top of the histogram. This makes a prettier chart.
      # The RGBA and intensity histograms are all drawn to the same scale.

      max = [red.max, green.max, blue.max, alpha.max, int.max].max
      scale = HISTOGRAM_ROWS / (max * AIR_FACTOR)

      charts = ImageList.new

      # Add the thumbnail.
      thumb = copy
      thumb['Label'] = File.basename(filename)
      charts << thumb

      # Compute the channel and intensity histograms.
      channel_hists = channel_histograms(red, green, blue, int, scale, fg, bg)

      # Add the red, green, and blue histograms to the list
      charts << channel_hists.shift
      charts << channel_hists.shift
      charts << channel_hists.shift

      # Add Alpha channel or image stats
      charts << if opaque?
                  info_text(fg, bg)
                else
                  alpha_hist(alpha, scale, fg, bg)
                end

      # Add the RGB histogram
      charts << channel_hists.shift

      # Add the intensity histogram.
      charts << intensity_hist(channel_hists.shift)

      # Add the color frequency histogram.
      charts << color_hist(fg, bg)

      # Make a montage.
      charts.montage do |options|
        options.background_color = bg
        options.stroke = 'transparent'
        options.fill = fg
        options.border_width = 1
        options.tile = '4x2'
        options.geometry = "#{HISTOGRAM_COLS}x#{HISTOGRAM_ROWS}+10+10"
      end
    end
  end
end

puts <<~END_INFO

  This example shows how to get pixel-level access to an image.
  Usage: histogram.rb <image-filename>

END_INFO

# Get filename from command line.
if ARGV[0]
  filename = ARGV[0]
else
  puts 'No filename argument. Defaulting to Flower_Hat.jpg'
  filename = '../doc/ex/images/Flower_Hat.jpg'
end

# Only process first frame if multi-frame image
image = Magick::Image.read(filename)
puts 'Charting 1st image' if image.length > 1
image = image.first

# Give the user something to look at while we're working.
name = File.basename(filename).sub(/\..*?$/, '')
$stdout.sync = true
printf "Creating #{name}_Histogram.png"

timer = Thread.new do
  loop do
    sleep(1)
    printf '.'
  end
end

# Generate the histograms
histogram = image.histogram(Magick::Pixel.from_color('white'), Magick::Pixel.from_color('black'))

# Write output file
histogram.compression = Magick::ZipCompression
histogram.write("./#{name}_Histogram.png")

Thread.kill(timer)
puts 'Done!'
exit
