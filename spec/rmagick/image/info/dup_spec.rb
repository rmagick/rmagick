# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#dup' do
  it 'copies the settings' do
    info = described_class.new
    info.size = '10x20'
    info['tiff', 'rows-per-strip'] = '8'

    [info.dup, info.clone].each do |copy|
      expect(copy.size).to eq('10x20')
      expect(copy['tiff', 'rows-per-strip']).to eq('8')
    end
  end

  it 'gives the copy a texture of its own' do
    info = described_class.new
    info.texture = Magick::Image.new(2, 2)
    copy = info.dup

    info.texture = nil

    expect { copy.texture = nil }.not_to output.to_stderr
  end

  it 'keeps the setting that a setter writes after its argument calls initialize_copy' do
    info = described_class.new
    other = described_class.new
    color = Object.new
    color.define_singleton_method(:to_str) do
      info.__send__(:initialize_copy, other)
      'red'
    end

    info.background_color = color

    expect(Magick::Pixel.from_color(info.background_color)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'raises TypeError when initialize_copy is called with an info of another class' do
    expect { Class.new(described_class).allocate.__send__(:initialize_copy, described_class.new) }.to raise_error(TypeError)
  end
end
