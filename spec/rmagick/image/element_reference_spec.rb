RSpec.describe Magick::Image, '#[]' do
  it 'allows accessing arbitrary properties' do
    image = described_class.new(20, 20)

    image['comment'] = 'str_1'
    image['label'] = 'str_2'
    image['jpeg:sampling-factor'] = '2x1,1x1,1x1'

    expect(image['comment']).to eq 'str_1'
    expect(image['label']).to eq 'str_2'
    expect(image['jpeg:sampling-factor']).to eq '2x1,1x1,1x1'
    expect(image['d']).to be nil
  end
end
