RSpec.describe Magick::Image, '#white_threshold' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.white_threshold }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50) }.not_to raise_error
    expect { @img.white_threshold(50, 50) }.not_to raise_error
    expect { @img.white_threshold(50, 50, 50) }.not_to raise_error
    expect { @img.white_threshold(50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50, 50, 50, alpha: 50) }.not_to raise_error
    expect { @img.white_threshold(50, 50, 50, wrong: 50) }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50, 50, 50, alpha: 50, extra: 50) }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    res = @img.white_threshold(50)
    expect(res).to be_instance_of(Magick::Image)
  end
end
