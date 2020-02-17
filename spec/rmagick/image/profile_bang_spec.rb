RSpec.describe Magick::Image, '#profile!' do
  it 'works' do
    image = described_class.new(20, 20)
    profile = described_class.read(IMAGE_WITH_PROFILE).first.color_profile

    res = image.profile!('*', nil)
    expect(res).to be(image)

    expect { image.profile!('icc', profile) }.not_to raise_error
    expect { image.profile!('iptc', 'xxx') }.not_to raise_error
    expect { image.profile!('icc', nil) }.not_to raise_error
    expect { image.profile!('iptc', nil) }.not_to raise_error

    expect { image.profile!('test', 'foobarbaz') }.to raise_error(ArgumentError)

    image.freeze
    expect { image.profile!('icc', 'xxx') }.to raise_error(FreezeError)
    expect { image.profile!('*', nil) }.to raise_error(FreezeError)
  end
end
