RSpec.describe Magick::Image, '#filename' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.filename }.not_to raise_error
    expect(img.filename).to eq('')
    expect { img.filename = 'xxx' }.to raise_error(NoMethodError)
  end
end
