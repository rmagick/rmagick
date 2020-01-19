RSpec.describe Magick::Image, '#dispatch' do
  it 'expects exactly 5 or 6 arguments' do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    expect { img.dispatch }.to raise_error(ArgumentError)
    expect { img.dispatch(0) }.to raise_error(ArgumentError)
    expect { img.dispatch(0, 0) }.to raise_error(ArgumentError)
    expect { img.dispatch(0, 0, img.columns) }.to raise_error(ArgumentError)
    expect do
      img.dispatch(0, 0, img.columns, img.rows)
    end.to raise_error(ArgumentError)
    expect do
      img.dispatch(0, 0, 20, 20, 'RGBA', false, false)
    end.to raise_error(ArgumentError)
  end
end
