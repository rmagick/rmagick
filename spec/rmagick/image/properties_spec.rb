RSpec.describe Magick::Image, '#properties' do
  let(:img) { Magick::Image.new(20, 20) }

  it 'returns a hash of assigned properties' do
    img['comment'] = 'str_1'
    img['label'] = 'str_2'
    img['jpeg:sampling-factor'] = '2x1,1x1,1x1'
    expected_properties = { 'comment' => 'str_1', 'label' => 'str_2', 'jpeg:sampling-factor' => '2x1,1x1,1x1' }

    expect(img.properties).to eq(expected_properties)
  end
end
