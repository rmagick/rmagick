# frozen_string_literal: true

RSpec.describe Magick::ImageList::Montage, '#texture=' do
  it 'works' do
    montage = described_class.new
    image = Magick::Image.new(10, 10)

    expect { montage.texture = image }.not_to raise_error
  end

  it 'accepts an ImageList argument' do
    montage = described_class.new

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)

    expect { montage.texture = image_list }.not_to raise_error
  end

  it "keeps an image written to mpr: under the number of its temporary image" do
    number = next_temp_image_number
    Magick::Image.new(2, 2) { |options| options.background_color = "blue" }.write("mpr:#{number}")
    red = Magick::Image.new(2, 2) { |options| options.background_color = "red" }

    described_class.new.texture = red

    expect(Magick::Image.read("mpr:#{number}").first.pixel_color(0, 0)).to eq(Magick::Pixel.from_color("blue"))
  end
end
