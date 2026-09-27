# frozen_string_literal: true

RSpec.describe Magick::Image, '#morphology' do
  it 'works' do
    image = described_class.new(20, 20)
    kernel = Magick::KernelInfo.new('Octagon')

    Magick::MorphologyMethod.values do |method|
      result = image.morphology(method, 2, kernel)
      expect(result).to be_instance_of(described_class)
      expect(result).not_to be(image)
    end
  end

  it 'rejects a kernel string that names a file with @' do
    image = described_class.new(20, 20)

    Tempfile.create(['kernel', '.txt']) do |file|
      file.write('3x3: 0,0,0 0,1,0 0,0,0')
      file.flush

      expect { image.morphology(Magick::DilateMorphology, 1, "@#{file.path}") }.to raise_error(ArgumentError, /must not name a file/)
    end
  end
end
