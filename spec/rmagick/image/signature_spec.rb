RSpec.describe Magick::Image, '#signature' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.signature
      expect(res).to be_instance_of(String)
    end.not_to raise_error
  end
end
