# frozen_string_literal: true

RSpec.describe Magick::Image, '#inspect' do
  it 'describes the image' do
    image = described_class.new(20, 20)
    image.define('user', 'foo')

    expect(image.inspect).to match(/ 20x20 DirectClass \d+-bit user:foo\z/)
  end

  # Regression: build_inspect_string added up the untruncated lengths snprintf
  # returns, so a format name too long for the 4096-byte buffer pushed the offset
  # past its end and the appends that followed wrote past the stack buffer.
  it 'truncates the description when the format name does not fit' do
    image = described_class.new(20, 20)
    image.define('user', 'foo')
    image_list = Magick::ImageList.new
    image_list << image

    # ImageMagick takes the format from the file name's extension, and
    # ImageList#to_blob copies it into the image before it fails to encode.
    expect { image_list.to_blob { |info| info.filename = "x.#{'a' * 5000}" } }.to raise_error(Magick::ImageMagickError)

    description = image.inspect
    expect(description).to include('A' * 4000)
    expect(description.length).to be < 4096
  end
end
