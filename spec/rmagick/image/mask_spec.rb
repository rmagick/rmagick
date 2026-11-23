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

  it 'releases what it holds when a call for a mask with alpha is interrupted or fails' do
    image = described_class.new(4, 4)
    mask = described_class.new(4, 4) { |options| options.background_color = 'none' }
    mask.alpha(Magick::ActivateAlphaChannel)

    expect(interrupt_each_call(Class.new(StandardError)) { image.mask(mask) }).to be_positive
    expect(fail_each_call { image.mask(mask) }).to be_positive
  end
end
