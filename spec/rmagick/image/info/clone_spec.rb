# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#clone' do
  it 'works' do
    info = described_class.new
    info.size = '10x20'

    copy = info.clone
    expect(copy).to be_instance_of(described_class)
    expect(copy).not_to be(info)
    expect(copy).not_to be_frozen
    expect(copy.size).to eq('10x20')
    expect(info.clone(freeze: false)).not_to be_frozen
  end

  it 'raises TypeError for freeze: true, as #freeze does' do
    info = described_class.new

    expect { info.clone(freeze: true) }.to raise_error(TypeError, "can't freeze Magick::Image::Info")
    expect { info.freeze }.to raise_error(TypeError, "can't freeze Magick::Image::Info")
  end

  it 'does not let its setters change an Info frozen another way' do
    info = described_class.new
    Kernel.instance_method(:freeze).bind_call(info)

    expect { info.caption = 'x' }.to raise_error(FrozenError)
    expect { info['tiff', 'rows-per-strip'] = '8' }.to raise_error(FrozenError)
    expect(info['tiff', 'rows-per-strip']).to be(nil)
  end

  it 'rejects an unexpected value for freeze as Object#clone does' do
    info = described_class.new

    expect { info.clone(freeze: 1) }.to raise_error(ArgumentError)
  end
end
