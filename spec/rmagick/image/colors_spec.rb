RSpec.describe Magick::Image, '#colors' do
  it 'works' do
    img1 = described_class.new(100, 100)

    expect { img1.colors }.not_to raise_error
    expect(img1.colors).to eq(0)
    img2 = img1.copy
    img2.class_type = Magick::PseudoClass
    expect(img2.colors).to be_kind_of(Integer)
    expect { img2.colors = 2 }.to raise_error(NoMethodError)
  end
end
