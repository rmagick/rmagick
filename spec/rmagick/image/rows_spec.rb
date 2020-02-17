RSpec.describe Magick::Image, '#rows' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.rows }.not_to raise_error
    expect(image.rows).to eq(100)
    expect { image.rows = 2 }.to raise_error(NoMethodError)
  end
end
