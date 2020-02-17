RSpec.describe Magick::Image, '#columns' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.columns }.not_to raise_error
    expect(image.columns).to eq(100)
    expect { image.columns = 2 }.to raise_error(NoMethodError)
  end
end
