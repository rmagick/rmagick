# frozen_string_literal: true

RSpec.describe Magick::ImageList::Montage, '#clone' do
  it 'works' do
    montage = described_class.new

    copy = montage.clone
    expect(copy).to be_instance_of(described_class)
    expect(copy).not_to be(montage)
    expect(copy).not_to be_frozen
    expect(montage.clone(freeze: false)).not_to be_frozen
  end

  it 'raises TypeError for freeze: true, as #freeze does' do
    montage = described_class.new

    expect { montage.clone(freeze: true) }.to raise_error(TypeError, "can't freeze Magick::ImageList::Montage")
    expect { montage.freeze }.to raise_error(TypeError, "can't freeze Magick::ImageList::Montage")
  end

  it 'does not let its setters change a Montage frozen another way' do
    montage = described_class.new
    Kernel.instance_method(:freeze).bind_call(montage)

    expect { montage.geometry = '10x10' }.to raise_error(FrozenError)
    expect { montage.texture = Magick::Image.new(2, 2) }.to raise_error(FrozenError)
  end

  it 'rejects an unexpected value for freeze as Object#clone does' do
    montage = described_class.new

    expect { montage.clone(freeze: 1) }.to raise_error(ArgumentError)
  end
end
