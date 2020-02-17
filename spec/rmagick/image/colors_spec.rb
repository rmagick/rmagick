RSpec.describe Magick::Image, '#colors' do
  it 'works' do
    image1 = described_class.new(100, 100)

    expect { image1.colors }.not_to raise_error
    expect(image1.colors).to eq(0)
    image2 = image1.copy
    image2.class_type = Magick::PseudoClass
    expect(image2.colors).to be_kind_of(Integer)
    expect { image2.colors = 2 }.to raise_error(NoMethodError)
  end
end
