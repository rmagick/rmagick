# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#texture' do
  it 'works' do
    info = described_class.new
    image = Magick::Image.read('granite:') { |options| options.size = '20x20' }

    expect { info.texture = image.first }.not_to raise_error
    expect { info.texture = nil }.not_to raise_error
  end
end
