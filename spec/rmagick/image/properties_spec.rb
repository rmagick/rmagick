RSpec.describe Magick::Image, '#properties' do
  it 'returns a hash of assigned properties' do
    image = described_class.new(20, 20)

    image['comment'] = 'str_1'
    image['label'] = 'str_2'
    image['jpeg:sampling-factor'] = '2x1,1x1,1x1'
    expected_properties = { 'comment' => 'str_1', 'label' => 'str_2', 'jpeg:sampling-factor' => '2x1,1x1,1x1' }

    expect(image.properties).to eq(expected_properties)
  end
end
