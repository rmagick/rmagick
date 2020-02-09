RSpec.describe Magick::Image, '#_load' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    res = img._dump(10)

    expect(described_class._load(res)).to be_instance_of(described_class)
  end
end
