RSpec.describe Magick::Image, '#colors' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.colors }.not_to raise_error
    expect(@img.colors).to eq(0)
    img2 = @img.copy
    img2.class_type = Magick::PseudoClass
    expect(img2.colors).to be_kind_of(Integer)
    expect { img2.colors = 2 }.to raise_error(NoMethodError)
  end
end
