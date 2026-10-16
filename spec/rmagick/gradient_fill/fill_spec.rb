# frozen_string_literal: true

RSpec.describe Magick::GradientFill, '#fill' do
  it 'works' do
    image = Magick::Image.new(10, 10)

    gradient = described_class.new(0, 0, 0, 0, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 0, 10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 10, 0, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 10, 10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 5, 20, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(-10, 0, -10, 10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, -10, 10, -10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, -10, 10, -20, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 100, 100, 200, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    imgl = Magick::ImageList.new
    imgl.new_image(10, 10)

    gradient = described_class.new(0, 0, 0, 0, '#900', '#000')
    obj = gradient.fill(imgl)
    expect(obj).to eq(gradient)
  end

  it 'keeps the image that #cur_image returns alive while it fills' do
    source = Object.new
    source.define_singleton_method(:cur_image) { Magick::Image.new(2, 2) }
    gradients = [[0, 0, 0, 0], [1, 0, 1, 2], [0, 1, 2, 1], [0, 0, 2, 1], [0, 0, 1, 2]].map do |points|
      described_class.new(*points, '#900', '#000')
    end

    expect do
      with_gc_stress { gradients.each { |gradient| gradient.fill(source) } }
    end.not_to raise_error
  end
end
