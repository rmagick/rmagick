# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '.builtin' do
  it 'works' do
    expect(described_class.builtin(Magick::UnityKernel, '')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::GaussianKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::LoGKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::DoGKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::BlurKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::CometKernel, '10,5')).to be_instance_of(described_class)
    expect { described_class.builtin(Magick::GaussianKernel, 'invalid') }.to raise_error(ArgumentError)
  end

  it 'fills in the arguments that are left out as KernelInfo.new does' do
    image = Magick::Image.new(9, 9) { |options| options.background_color = 'black' }
    image.pixel_color(4, 4, 'white')

    dilated = image.morphology(Magick::DilateMorphology, 1, described_class.builtin(Magick::DiamondKernel, '1'))
    white = dilated.get_pixels(0, 0, 9, 9).count { |pixel| pixel.red == Magick::QuantumRange }
    expect(white).to eq(5)
  end

  it 'rejects a geometry that adds another kernel' do
    expect { described_class.builtin(Magick::DiamondKernel, '1;Square') }.to raise_error(ArgumentError)
  end
end
