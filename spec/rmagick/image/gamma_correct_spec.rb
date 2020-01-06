RSpec.describe Magick::Image, '#gamma_correct' do
  it 'works' do
    img = described_class.new(20, 20)

    expect { img.gamma_correct }.to raise_error(ArgumentError)
    expect do
      res = img.gamma_correct(0.8)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error
    expect { img.gamma_correct(0.8, 0.9) }.not_to raise_error
    expect { img.gamma_correct(0.8, 0.9, 1.0) }.not_to raise_error
    expect { img.gamma_correct(0.8, 0.9, 1.0, 1.1) }.not_to raise_error
    # too many arguments
    expect { img.gamma_correct(0.8, 0.9, 1.0, 1.1, 2) }.to raise_error(ArgumentError)
  end
end
