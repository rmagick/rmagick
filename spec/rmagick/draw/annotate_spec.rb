# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Magick::Draw, '#annotate' do
  it 'works' do
    draw = described_class.new

    image = Magick::Image.new(10, 10)
    draw.annotate(image, 0, 0, 0, 20, 'Hello world')

    yield_obj = nil
    draw.annotate(image, 100, 100, 20, 20, 'Hello world 2') do |draw2|
      yield_obj = draw2
    end
    expect(yield_obj).to be_instance_of(described_class)

    expect do
      image = Magick::Image.new(10, 10)
      draw.annotate(image, 0, 0, 0, 20, nil)
    end.to raise_error(TypeError)

    expect { draw.annotate('x', 0, 0, 0, 20, 'Hello world') }.to raise_error(NoMethodError)
  end

  it 'works with string started with @ (issue 38)' do
    draw = described_class.new

    image = Magick::Image.new(10, 10)
    expect { draw.annotate(image, 0, 0, 0, 20, '@Hello world') }.not_to raise_error

    yield_obj = nil
    draw.annotate(image, 100, 100, 20, 20, '@Hello world 2') do |draw2|
      yield_obj = draw2
    end
    expect(yield_obj).to be_instance_of(described_class)
  end

  # Regression: the text was handed to InterpretImageProperties(), which reads
  # the annotation text out of the named file when the first non-blank character
  # is '@'. Caller-supplied text was therefore an arbitrary local file read whose
  # contents were rasterized into the image.
  it 'draws text starting with @ instead of the contents of that file' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'canary.txt')
      File.write(path, 'SECRET')

      draw = described_class.new
      draw.pointsize = 12

      rendered = lambda do |text|
        image = Magick::Image.new(300, 40) { |options| options.background_color = 'white' }
        described_class.new.tap { |d| d.pointsize = 12 }.annotate(image, 0, 0, 0, 20, text)
        image.export_pixels(0, 0, 300, 40, 'I')
      end

      expect(rendered.call("@#{path}")).not_to eq(rendered.call('SECRET'))
      expect(draw.get_type_metrics(Magick::Image.new(10, 10), "@#{path}").width)
        .not_to eq(draw.get_type_metrics(Magick::Image.new(10, 10), 'SECRET').width)
    end
  end

  it 'still expands percent escapes' do
    image = Magick::Image.new(123, 10)
    draw = described_class.new

    expect(draw.get_type_metrics(image, '%[width]').width)
      .to eq(draw.get_type_metrics(image, '123').width)
  end

  it 'accepts an ImageList argument' do
    draw = described_class.new

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { draw.annotate(image_list, 0, 0, 0, 20, 'Hello world') }.not_to raise_error
  end

  it 'does not trigger a buffer overflow' do
    draw = described_class.new

    expect do
      if 1.size == 8
        # 64-bit environment can use larger value for Integer and it can cause
        # a stack buffer overflow.
        image = Magick::Image.new(10, 10)
        draw.annotate(image, 2**63, 2**63, 2**62, 2**62, 'Hello world')
      end
    end.not_to raise_error
  end

  it 'does not free the annotation text twice when the text raises an exception' do
    image = Magick::Image.new(10, 10)

    expect do
      described_class.new.annotate(image, 0, 0, 0, 20, '%[fx:(]')
    end.to raise_error(Magick::ImageMagickError)

    # The Draw object is garbage now. Reclaiming it must not free the
    # annotation text a second time.
    GC.start
  end
end
