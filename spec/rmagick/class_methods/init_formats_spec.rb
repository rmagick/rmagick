RSpec.describe Magick, '.init_formats' do
  it 'works' do
    expect(described_class.init_formats).to be_instance_of(Hash)
  end
end
