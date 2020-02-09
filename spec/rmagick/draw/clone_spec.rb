RSpec.describe Magick::Draw, '#clone' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    @draw.freeze
    clone = @draw.clone
    expect(clone).to be_instance_of(described_class)
  end
end
