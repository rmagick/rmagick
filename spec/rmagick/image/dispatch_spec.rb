RSpec.describe Magick::Image, '#dispatch' do
  it 'expects exactly 5 or 6 arguments' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect { image.dispatch }.to raise_error(ArgumentError)
    expect { image.dispatch(0) }.to raise_error(ArgumentError)
    expect { image.dispatch(0, 0) }.to raise_error(ArgumentError)
    expect { image.dispatch(0, 0, image.columns) }.to raise_error(ArgumentError)
    expect do
      image.dispatch(0, 0, image.columns, image.rows)
    end.to raise_error(ArgumentError)
    expect do
      image.dispatch(0, 0, 20, 20, 'RGBA', false, false)
    end.to raise_error(ArgumentError)
  end
end
