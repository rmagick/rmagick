RSpec.describe Magick::Image, '#base_filename' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.base_filename }.not_to raise_error
    expect(img.base_filename).to eq('')
    expect { img.base_filename = 'xxx' }.to raise_error(NoMethodError)
  end
end
