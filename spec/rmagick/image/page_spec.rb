# frozen_string_literal: true

RSpec.describe Magick::Image, '#page' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.page }.not_to raise_error
    page = image.page
    expect(page.width).to eq(0)
    expect(page.height).to eq(0)
    expect(page.x).to eq(0)
    expect(page.y).to eq(0)
    page = Magick::Rectangle.new(1, 2, 3, 4)
    expect { image.page = page }.not_to raise_error
    expect(page.width).to eq(1)
    expect(page.height).to eq(2)
    expect(page.x).to eq(3)
    expect(page.y).to eq(4)
    expect { image.page = 2 }.to raise_error(TypeError)
  end

  it "raises TypeError when Rectangle#values does not return an Array" do
    image = described_class.new(100, 100)
    page = Magick::Rectangle.new(1, 2, 3, 4)
    allow_any_instance_of(Magick::Rectangle).to receive(:values).and_return(nil) # rubocop:disable RSpec/AnyInstance

    expect { image.page = page }
      .to raise_error(TypeError, "Magick::Rectangle#values must return an Array (NilClass given)")
  end

  it 'accepts a subclass of Rectangle and a Rectangle with a singleton method' do
    image = described_class.new(100, 100)
    rectangle = Magick::Rectangle.new(1, 2, 3, 4)
    rectangle.define_singleton_method(:label) { 'page' }

    image.page = rectangle
    expect(image.page.to_a).to eq([1, 2, 3, 4])

    image.page = Class.new(Magick::Rectangle).new(5, 6, 7, 8)
    expect(image.page.to_a).to eq([5, 6, 7, 8])
  end
end
