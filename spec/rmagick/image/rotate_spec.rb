RSpec.describe Magick::Image, '#rotate' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.rotate(45)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { img.rotate(-45) }.not_to raise_error

    img = described_class.new(100, 50)
    expect do
      res = img.rotate(90, '>')
      expect(res).to be_instance_of(described_class)
      expect(res.columns).to eq(50)
      expect(res.rows).to eq(100)
    end.not_to raise_error
    expect do
      res = img.rotate(90, '<')
      expect(res).to be(nil)
    end.not_to raise_error
    expect { img.rotate(90, 't') }.to raise_error(ArgumentError)
    expect { img.rotate(90, []) }.to raise_error(TypeError)
  end
end
