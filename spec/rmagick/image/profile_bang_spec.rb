RSpec.describe Magick::Image, '#profile!' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.profile!('*', nil)
      expect(res).to be(@img)
    end.not_to raise_error
    expect { @img.profile!('icc', @p) }.not_to raise_error
    expect { @img.profile!('iptc', 'xxx') }.not_to raise_error
    expect { @img.profile!('icc', nil) }.not_to raise_error
    expect { @img.profile!('iptc', nil) }.not_to raise_error

    expect { @img.profile!('test', 'foobarbaz') }.to raise_error(ArgumentError)

    @img.freeze
    expect { @img.profile!('icc', 'xxx') }.to raise_error(FreezeError)
    expect { @img.profile!('*', nil) }.to raise_error(FreezeError)
  end
end
