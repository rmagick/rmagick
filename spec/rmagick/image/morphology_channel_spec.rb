RSpec.describe Magick::Image, '#morphology_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.morphology_channel }.to raise_error(ArgumentError)
    expect { image.morphology_channel(Magick::RedChannel) }.to raise_error(ArgumentError)
    expect { image.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology) }.to raise_error(ArgumentError)
    expect { image.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2) }.to raise_error(ArgumentError)
    expect { image.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2, :not_kernel_info) }.to raise_error(ArgumentError)

    kernel = Magick::KernelInfo.new('Octagon')

    result = image.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2, kernel)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)
  end
end
