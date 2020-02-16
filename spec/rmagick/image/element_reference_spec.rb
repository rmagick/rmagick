RSpec.describe Magick::Image, '#[]' do
  it 'allows accessing arbitrary properties' do
    img = described_class.new(20, 20)

    img['comment'] = 'str_1'
    img['label'] = 'str_2'
    img['jpeg:sampling-factor'] = '2x1,1x1,1x1'

    expect(img['comment']).to eq 'str_1'
    expect(img['label']).to eq 'str_2'
    expect(img['jpeg:sampling-factor']).to eq '2x1,1x1,1x1'
    expect(img['d']).to be nil
  end
end
