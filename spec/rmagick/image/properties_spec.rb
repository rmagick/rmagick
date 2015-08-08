RSpec.describe Magick::Image, '#properties' do

  let(:img) { Magick::Image.new(20, 20) }
  let(:freeze_error) { RUBY_VERSION[/^1\.9|^2/] ? RuntimeError : TypeError }

  before(:each) do
    img['a'] = 'str_1'
    img['b'] = 'str_2'
    img['c'] = 'str_3'
  end

  it 'allows assignment of arbitrary properties' do
    expect(img['a']).to eq 'str_1'
    expect(img['b']).to eq 'str_2'
    expect(img['c']).to eq 'str_3'
    expect(img['d']).to be nil
  end

  it 'returns a hash of assigned properties' do
    expected_properties = { 'a' => 'str_1', 'b' => 'str_2', 'c' => 'str_3' }
    expect(img.properties).to eq(expected_properties)
  end

  it 'raises an error when trying to assign properties to a frozen image' do
    img.freeze
    expect { img['d'] = 'str_4' }.to raise_error(freeze_error)
  end

end
