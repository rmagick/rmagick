# frozen_string_literal: true

RSpec.describe Magick::Image, '#density' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.density }.not_to raise_error
    expect { image.density = '90x90' }.not_to raise_error
    expect { image.density = 'x90' }.not_to raise_error
    expect { image.density = '90' }.not_to raise_error
    expect { image.density = Magick::Geometry.new(image.columns / 2, image.rows / 2, 5, 5) }.not_to raise_error
    expect { image.density = 2 }.to raise_error(TypeError)
  end

  it 'accepts a subclass of Geometry and a Geometry with a singleton method' do
    image = described_class.new(100, 100)
    singleton = Magick::Geometry.new(72, 36)
    singleton.define_singleton_method(:label) { 'density' }

    image.density = singleton
    expect(image.density).to eq('72x36')

    image.density = Class.new(Magick::Geometry).new(96, 48)
    expect(image.density).to eq('96x48')
  end
end
