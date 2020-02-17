RSpec.describe Magick::Image, '#rotate' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.rotate(45)
    expect(res).to be_instance_of(described_class)

    expect { image.rotate(-45) }.not_to raise_error

    image = described_class.new(100, 50)

    res = image.rotate(90, '>')
    expect(res).to be_instance_of(described_class)
    expect(res.columns).to eq(50)
    expect(res.rows).to eq(100)

    res = image.rotate(90, '<')
    expect(res).to be(nil)

    expect { image.rotate(90, 't') }.to raise_error(ArgumentError)
    expect { image.rotate(90, []) }.to raise_error(TypeError)
  end
end
