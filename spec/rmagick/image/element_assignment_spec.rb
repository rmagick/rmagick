RSpec.describe Magick::Image, '#[]=' do
  let(:img) { described_class.new(20, 20) }

  it 'allows assignment of arbitrary properties' do
    img['comment'] = 'str_1'
    img['label'] = 'str_2'
    img['jpeg:sampling-factor'] = '2x1,1x1,1x1'

    expect(img['comment']).to eq 'str_1'
    expect(img['label']).to eq 'str_2'
    expect(img['jpeg:sampling-factor']).to eq '2x1,1x1,1x1'
  end

  it 'raises an error when trying to assign properties to a frozen image' do
    img.freeze

    expect { img['comment'] = 'str_4' }.to raise_error(RuntimeError)
  end
end
