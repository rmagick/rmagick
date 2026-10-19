# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#texture' do
  it 'works' do
    info = described_class.new
    image = Magick::Image.read('granite:') { |options| options.size = '20x20' }

    expect { info.texture = image.first }.not_to raise_error
    expect { info.texture = nil }.not_to raise_error
  end

  it "keeps an image written to mpr: under the number of its temporary image" do
    number = next_temp_image_number
    Magick::Image.new(2, 2) { |options| options.background_color = "blue" }.write("mpr:#{number}")
    red = Magick::Image.new(2, 2) { |options| options.background_color = "red" }

    described_class.new.texture = red

    expect(Magick::Image.read("mpr:#{number}").first.pixel_color(0, 0)).to eq(Magick::Pixel.from_color("blue"))
  end
end
