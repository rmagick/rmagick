# frozen_string_literal: true

RSpec.describe Magick::Image, '#marshal' do
  it 'works' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    d = nil
    image2 = nil
    expect { d = Marshal.dump(image) }.not_to raise_error
    expect { image2 = Marshal.load(d) }.not_to raise_error
    pending_on_im6_gif_bug
    expect(image2).to eq(image)
  end
end
