RSpec.describe Magick, '.init_formats' do
  it 'works' do
    expect(Magick.init_formats).to be_instance_of(Hash)
  end
end
