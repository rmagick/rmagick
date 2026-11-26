# frozen_string_literal: true

RSpec.describe Magick::Image, '#mask' do
  it 'works' do
    image1 = described_class.new(20, 20)
    cimage = described_class.new(10, 10)

    image1.mask(cimage)

    result = image1.mask
    expect(result).not_to be(nil)
    expect(result).not_to be(cimage)
    expect(result.columns).to eq(20)
    expect(result.rows).to eq(20)

    expect { image1.mask(cimage, 'x') }.to raise_error(ArgumentError)
    # mask expects an Image and calls `cur_image'
    expect { image1.mask = 2 }.to raise_error(NoMethodError)

    image2 = image1.copy.freeze
    expect { image2.mask cimage }.to raise_error(FrozenError)

    image1.destroy!
    expect { image1.mask cimage }.to raise_error(Magick::DestroyedImageError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.mask(image_list) }.not_to raise_error
  end

  it 'frees the copy of the mask when the thread is interrupted' do
    cancelled = Class.new(StandardError)
    GC.start
    baseline = Magick.resource_usage(:memory)
    image = described_class.new(1000, 1000)
    mask = described_class.new(1000, 1000)
    allocated = Magick.resource_usage(:memory)
    interrupt(cancelled, ready: -> { Magick.resource_usage(:memory) > allocated }) { image.mask(mask) }
    image.destroy!
    mask.destroy!
    3.times { GC.start }

    expect(Magick.resource_usage(:memory)).to be <= baseline
  end

  it 'frees the copy of the mask when the image is frozen while it copies the mask' do
    image = described_class.new(1000, 1000)
    GC.start
    baseline = Magick.resource_usage(:memory)
    mask = described_class.new(1000, 1000)

    expect { during_call(-> { image.freeze }) { image.mask(mask) } }.to raise_error(FrozenError)
    mask.destroy!
    3.times { GC.start }

    expect(Magick.resource_usage(:memory)).to be <= baseline
  end

  it "releases what it holds when one of its calls is interrupted" do
    image = described_class.new(4, 4)
    mask = described_class.new(4, 4)

    expect(interrupt_each_call(Class.new(StandardError)) { image.mask(mask) }).to be_positive
  end

  it "frees the copy of the mask when one of its calls fails" do
    GC.start
    baseline = Magick.resource_usage(:memory)
    image = described_class.new(16, 16)
    mask = described_class.new(8, 8)
    calls = fail_each_call { image.mask(mask) }
    image.destroy!
    mask.destroy!
    3.times { GC.start }

    expect(calls).to be_positive
    expect(Magick.resource_usage(:memory)).to be <= baseline
  end

  it 'uses the alpha of a mask that has one' do
    mask = described_class.new(4, 1) { |options| options.background_color = 'none' }
    mask.alpha(Magick::ActivateAlphaChannel)
    %w[white rgba(255,255,255,0) black rgba(0,0,0,0)].each_with_index { |color, x| mask.pixel_color(x, 0, color) }
    image = described_class.new(4, 1) { |options| options.background_color = 'red' }

    image.mask(mask)
    draw = Magick::Draw.new
    draw.fill('blue')
    draw.rectangle(0, 0, 3, 0)
    draw.draw(image)

    changed = (0..3).map { |x| image.pixel_color(x, 0).blue > Magick::QuantumRange / 2 }
    expect(changed).to eq([true, false, true, false])
  end

  it 'uses the intensity of a mask whose alpha is deactivated' do
    mask = described_class.new(2, 1)
    mask.pixel_color(1, 0, 'black')
    mask.alpha(Magick::ActivateAlphaChannel)
    mask.alpha(Magick::DeactivateAlphaChannel)
    image = described_class.new(2, 1) { |options| options.background_color = 'red' }

    image.mask(mask)
    draw = Magick::Draw.new
    draw.fill('blue')
    draw.rectangle(0, 0, 1, 0)
    draw.draw(image)

    changed = (0..1).map { |x| image.pixel_color(x, 0).blue > Magick::QuantumRange / 2 }
    expect(changed).to eq([false, true])
  end

  it 'reads the alpha the same way whatever the colorspace of the mask' do
    mask = described_class.new(1, 1) { |options| options.background_color = 'none' }
    mask.alpha(Magick::ActivateAlphaChannel)
    mask.pixel_color(0, 0, 'rgba(255,255,255,0.75)')
    mask.colorspace = Magick::RGBColorspace
    image = described_class.new(1, 1)

    image.mask(mask)

    expect(image.mask.pixel_color(0, 0).red).to be_within(1).of(Magick::QuantumRange * 0.25)
  end

  it 'uses an alpha copied from the intensity' do
    mask = described_class.new(2, 1)
    mask.pixel_color(1, 0, 'black')
    mask.alpha(Magick::CopyAlphaChannel)
    image = described_class.new(2, 1) { |options| options.background_color = 'red' }

    image.mask(mask)
    draw = Magick::Draw.new
    draw.fill('blue')
    draw.rectangle(0, 0, 1, 0)
    draw.draw(image)

    changed = (0..1).map { |x| image.pixel_color(x, 0).blue > Magick::QuantumRange / 2 }
    expect(changed).to eq([true, false])
  end

  it 'reads the alpha of a mask that has a mask of its own' do
    mask = described_class.new(4, 1) { |options| options.background_color = 'none' }
    mask.alpha(Magick::ActivateAlphaChannel)
    %w[white rgba(255,255,255,0) black rgba(0,0,0,0)].each_with_index { |color, x| mask.pixel_color(x, 0, color) }
    mask.mask(described_class.new(4, 1) { |options| options.background_color = 'white' })
    image = described_class.new(4, 1) { |options| options.background_color = 'red' }

    image.mask(mask)
    draw = Magick::Draw.new
    draw.fill('blue')
    draw.rectangle(0, 0, 3, 0)
    draw.draw(image)

    changed = (0..3).map { |x| image.pixel_color(x, 0).blue > Magick::QuantumRange / 2 }
    expect(changed).to eq([true, false, true, false])
  end

  it 'resizes a mask of another size before it uses it' do
    results = [2, 8].map do |columns|
      mask = described_class.new(columns, 1)
      image = described_class.new(4, 1) { |options| options.background_color = 'red' }

      image.mask(mask)
      values = (0..3).map { |x| image.mask.pixel_color(x, 0).red }
      draw = Magick::Draw.new
      draw.fill('blue')
      draw.rectangle(0, 0, 3, 0)
      draw.draw(image)

      [values, (0..3).map { |x| image.pixel_color(x, 0).blue > Magick::QuantumRange / 2 }]
    end

    expect(results).to eq([[[Magick::QuantumRange] * 4, [false] * 4]] * 2)
  end

  it 'resizes a mask with alpha before it reads the alpha' do
    mask = described_class.new(7, 1) { |options| options.background_color = 'none' }
    mask.alpha(Magick::ActivateAlphaChannel)
    mask.pixel_color(2, 0, 'white')
    image = described_class.new(4, 1)

    image.mask(mask)

    resized = mask.resize(4, 1)
    expected = (0..3).map { |x| (Magick::QuantumRange - resized.pixel_color(x, 0).alpha).clamp(0, Magick::QuantumRange) }
    # With HDRI, a channel rounds down, so the inverted alpha can be one more.
    expect((0..3).map { |x| image.mask.pixel_color(x, 0).red }).to match(expected.map { |value| a_value_within(1).of(value) })
  end

  it 'keeps the values of an enlarged mask with alpha within the range' do
    mask = described_class.new(2, 1) { |options| options.background_color = 'none' }
    mask.alpha(Magick::ActivateAlphaChannel)
    mask.pixel_color(0, 0, 'black')
    image = described_class.new(4, 1)

    image.mask(mask)
    values = (0..3).map { |x| image.mask.pixel_color(x, 0).red }
    image.mask(mask.resize(4, 1))
    values += (0..3).map { |x| image.mask.pixel_color(x, 0).red }

    expect(values).to all(be_between(0, Magick::QuantumRange))
  end

  it 'resizes a mask that has a mask of its own as one without it' do
    mask = described_class.new(2, 1)
    mask.pixel_color(0, 0, 'black')

    values = [['black', 6], ['black', 1], ['white', 6], ['white', 1]].map do |color, columns|
      nested = mask.copy
      nested.mask(described_class.new(2, 1) { |options| options.background_color = color })
      image = described_class.new(columns, 1)
      [nested, mask].map do |source|
        image.mask(source)
        (0...columns).map { |x| image.mask.pixel_color(x, 0).red }
      end
    end

    expect(values.map(&:first)).to eq(values.map(&:last))
  end

  it 'keeps the image usable when ImageMagick runs out of resources' do
    image = described_class.new(20, 20) { |options| options.background_color = 'red' }
    mask = described_class.new(20, 20)
    source = described_class.new(20, 20) { |options| options.background_color = 'blue' }

    expect { without_resources { image.mask(mask) } }.to raise_error(Magick::ImageMagickError)
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)
    expect(result.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('blue'))
  end

  it 'keeps the mask and the image usable when removing the mask runs out of resources', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) >= Gem::Version.new('7.0.0') do
    image = described_class.new(20, 20) { |options| options.background_color = 'red' }
    image.mask(described_class.new(20, 20))
    source = described_class.new(20, 20) { |options| options.background_color = 'blue' }

    expect { without_resources { image.mask(nil) } }.to raise_error(Magick::ImageMagickError)
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)
    expect(result.pixel_color(0, 0)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'keeps the composite mask when it removes the mask' do
    image = described_class.new(2, 1) { |options| options.background_color = 'red' }
    image.mask(described_class.new(2, 1))
    compose_mask = described_class.new(2, 1)
    compose_mask.pixel_color(0, 0, 'black')
    image.add_compose_mask(compose_mask)
    source = described_class.new(2, 1) { |options| options.background_color = 'blue' }

    image.mask(nil)
    result = image.composite(source, 0, 0, Magick::OverCompositeOp)

    expect(image.mask).to be(nil)
    changed = (0..1).map { |x| result.pixel_color(x, 0).blue > Magick::QuantumRange / 2 }
    expect(changed).to eq([false, true])
  end

  it 'needs no resources to remove a mask that the image does not have' do
    image = described_class.new(20, 20)

    expect { without_resources { image.mask(nil) } }.not_to raise_error
    expect(image.mask).to be(nil)
  end

  it 'frees the images it makes from a mask with alpha when one of its calls is interrupted or fails' do
    GC.start
    baseline = Magick.resource_usage(:memory)
    image = described_class.new(16, 16)
    mask = described_class.new(8, 8) { |options| options.background_color = 'none' }
    mask.alpha(Magick::ActivateAlphaChannel)
    mask.mask(described_class.new(8, 8) { |options| options.background_color = 'black' })
    interrupted = interrupt_each_call(Class.new(StandardError)) { image.mask(mask) }
    failed = fail_each_call { image.mask(mask) }
    image.destroy!
    mask.destroy!
    3.times { GC.start }

    expect(interrupted).to be_positive
    expect(failed).to be_positive
    expect(Magick.resource_usage(:memory)).to be <= baseline
  end
end
