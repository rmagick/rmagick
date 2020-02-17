RSpec.describe Magick::Image, '#base_columns' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.base_columns }.not_to raise_error
    expect(image.base_columns).to eq(0)
    expect { image.base_columns = 1 }.to raise_error(NoMethodError)
  end
end
