# frozen_string_literal: true

RSpec.describe Magick::ImageList::Montage, '#dup' do
  it 'copies the settings' do
    list = Magick::ImageList.new
    2.times { list << Magick::Image.new(10, 10) }
    texture = Magick::Image.new(4, 4) { |options| options.background_color = 'blue' }
    montage = described_class.new
    montage.background_color = 'red'
    montage.geometry = '10x10+2+2'
    montage.texture = texture
    expected = list.montage do |given|
      given.background_color = 'red'
      given.geometry = '10x10+2+2'
      given.texture = texture
    end

    [montage.dup, montage.clone].each do |copy|
      result = list.montage { |given| given.__send__(:initialize_copy, copy) }
      expect(result.first.export_pixels).to eq(expected.first.export_pixels)
    end
  end

  it 'gives the copy a texture of its own' do
    montage = described_class.new
    montage.texture = Magick::Image.new(2, 2)
    copy = montage.dup

    montage.texture = Magick::Image.new(2, 2)

    expect { copy.texture = Magick::Image.new(2, 2) }.not_to output.to_stderr
  end
end
