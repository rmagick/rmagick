RSpec.describe Magick::Image, '#properties' do
  let(:img) { Magick::Image.new(20, 20) }
  let(:freeze_error) { RuntimeError }

  before(:each) do
    img['comment'] = 'str_1'
    img['label'] = 'str_2'
    img['jpeg:sampling-factor'] = '2x1,1x1,1x1'
  end

  it 'allows assignment of arbitrary properties' do
    expect(img['comment']).to eq 'str_1'
    expect(img['label']).to eq 'str_2'
    expect(img['jpeg:sampling-factor']).to eq '2x1,1x1,1x1'
    expect(img['d']).to be nil
  end

  it 'returns a hash of assigned properties' do
    expected_properties = { 'comment' => 'str_1', 'label' => 'str_2', 'jpeg:sampling-factor' => '2x1,1x1,1x1' }
    expect(img.properties).to eq(expected_properties)
  end

  it 'raises an error when trying to assign properties to a frozen image' do
    img.freeze
    expect { img['comment'] = 'str_4' }.to raise_error(freeze_error)
  end
end
