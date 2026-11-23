# frozen_string_literal: true

RSpec.describe Magick::Image::View::Pixels, '#alpha' do
  it 'works' do
    image = Magick::Image.new(3, 2)
    image.alpha(Magick::OpaqueAlphaChannel)

    image.view(0, 0, 3, 2) do |view|
      expect(view[0][].alpha).to eq([Magick::QuantumRange] * 3)

      view[0][].alpha = 123
      expect(view[0][].alpha).to eq([123] * 3)
    end

    expect(image.pixel_color(1, 0).alpha).to eq(123)
    expect(image.pixel_color(1, 1).alpha).to eq(Magick::QuantumRange)
  end
end
