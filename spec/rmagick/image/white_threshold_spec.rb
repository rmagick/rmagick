RSpec.describe Magick::Image, '#white_threshold' do
  it 'works' do
    img1 = described_class.new(20, 20)

    expect { img1.white_threshold }.to raise_error(ArgumentError)
    expect { img1.white_threshold(50) }.not_to raise_error
    expect { img1.white_threshold(50, 50) }.not_to raise_error
    expect { img1.white_threshold(50, 50, 50) }.not_to raise_error
    expect { img1.white_threshold(50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { img1.white_threshold(50, 50, 50, alpha: 50) }.not_to raise_error
    expect { img1.white_threshold(50, 50, 50, wrong: 50) }.to raise_error(ArgumentError)
    expect { img1.white_threshold(50, 50, 50, alpha: 50, extra: 50) }.to raise_error(ArgumentError)
    expect { img1.white_threshold(50, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    res = img1.white_threshold(50)
    expect(res).to be_instance_of(described_class)
  end
end
