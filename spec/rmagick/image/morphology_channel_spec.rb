RSpec.describe Magick::Image, '#morphology_channel' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect { @img.morphology_channel }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel) }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology) }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2) }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2, :not_kernel_info) }.to raise_error(ArgumentError)

    kernel = Magick::KernelInfo.new('Octagon')
    expect do
      res = @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2, kernel)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end
end
