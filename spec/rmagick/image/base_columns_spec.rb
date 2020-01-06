RSpec.describe Magick::Image, '#base_columns' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.base_columns }.not_to raise_error
    expect(img.base_columns).to eq(0)
    expect { img.base_columns = 1 }.to raise_error(NoMethodError)
  end
end
