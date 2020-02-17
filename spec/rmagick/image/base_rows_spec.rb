RSpec.describe Magick::Image, '#base_rows' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.base_rows }.not_to raise_error
    expect(image.base_rows).to eq(0)
    expect { image.base_rows = 1 }.to raise_error(NoMethodError)
  end
end
