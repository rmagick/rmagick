module Magick
  class Draw
    def self._dummy_img_
      @@_dummy_img_
    end
  end
end

RSpec.describe Magick::Draw, '._dummy_img_' do
  let(:draw) { described_class.new }

  it 'works' do
    # cause it to become defined. save the object id.
    draw.get_type_metrics('ABCDEF')
    dummy = nil
    expect { dummy = described_class._dummy_img_ }.not_to raise_error

    expect(dummy).to be_instance_of(Magick::Image)

    # ensure that it is always the same object
    draw.get_type_metrics('ABCDEF')
    dummy2 = nil
    expect { dummy2 = described_class._dummy_img_ }.not_to raise_error
    expect(dummy).to eq dummy2
  end
end
