RSpec.describe Magick::Draw, '#clone' do
  it 'works' do
    draw = described_class.new

    draw.freeze
    clone = draw.clone
    expect(clone).to be_instance_of(described_class)
  end
end
