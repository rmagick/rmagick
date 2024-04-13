# frozen_string_literal: true

RSpec.describe Magick::Image, '#profile!' do
  it 'works' do
    image = described_class.new(20, 20)
    profile = described_class.read(IMAGE_WITH_PROFILE).first.color_profile

    result = image.profile!('*', nil)
    expect(result).to be(image)

    expect { image.profile!('icc', profile) }.not_to raise_error
    expect { image.profile!('iptc', 'xxx') }.not_to raise_error
    expect { image.profile!('icc', nil) }.not_to raise_error
    expect { image.profile!('iptc', nil) }.not_to raise_error

    expect { image.profile!('test', 'foobarbaz') }.to raise_error(ArgumentError)

    image.freeze
    expect { image.profile!('icc', 'xxx') }.to raise_error(FreezeError)
    expect { image.profile!('*', nil) }.to raise_error(FreezeError)
  end

  it 'delete exif when nil given as profile' do
    image = described_class.read(IMAGE_WITH_PROFILE).first
    expect(image.get_exif_by_number).to be_kind_of(Hash)
    expect(image.get_exif_by_number(305)).to eq({ 305 => "Adobe Photoshop CS Macintosh" })

    image.profile!('*', nil)
    blob = image.to_blob

    new_image = described_class.from_blob(blob).first
    expect(new_image.get_exif_by_number).to eq({})
  end
end
