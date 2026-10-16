# frozen_string_literal: true

RSpec.describe Magick::ImageList::Montage, '#dup' do
  it 'gives the copy a texture of its own' do
    montage = described_class.new
    montage.texture = Magick::Image.new(2, 2)
    copy = montage.dup

    montage.texture = Magick::Image.new(2, 2)

    expect { copy.texture = Magick::Image.new(2, 2) }.not_to output.to_stderr
  end
end
