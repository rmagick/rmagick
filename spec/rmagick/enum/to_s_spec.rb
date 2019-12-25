RSpec.describe Magick::Enum, '#to_s' do
  it 'works' do
    enum = Magick::Enum.new(:foo, 42)
    expect(enum.to_s).to eq('foo')

    enum = Magick::Enum.new('foo', 42)
    expect(enum.to_s).to eq('foo')
  end
end
