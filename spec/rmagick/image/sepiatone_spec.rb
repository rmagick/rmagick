RSpec.describe Magick::Image, '#sepiatone' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.sepiatone
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sepiatone(Magick::QuantumRange * 0.80) }.not_to raise_error
    expect { @img.sepiatone(Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { @img.sepiatone('x') }.to raise_error(TypeError)
  end
end
