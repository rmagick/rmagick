RSpec.describe Magick::Image, '#motion_blur' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.motion_blur(1.0, 7.0, 180)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.motion_blur(1.0, 0.0, 180) }.to raise_error(ArgumentError)
    expect { @img.motion_blur(1.0, -1.0, 180) }.not_to raise_error
  end
end
