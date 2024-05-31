# frozen_string_literal: true

RSpec.describe Magick::ImageList, '#destroy!' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.destroy!

    image_list.to_a.each do |image|
      expect(image.destroyed?).to be(true)
    end
  end
end
