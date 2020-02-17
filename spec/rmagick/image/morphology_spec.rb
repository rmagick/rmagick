RSpec.describe Magick::Image, '#morphology' do
  it 'works' do
    img = described_class.new(20, 20)
    kernel = Magick::KernelInfo.new('Octagon')

    Magick::MorphologyMethod.values do |method|
      res = img.morphology(method, 2, kernel)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end
  end
end
