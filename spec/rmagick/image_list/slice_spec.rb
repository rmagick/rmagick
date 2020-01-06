RSpec.describe Magick::ImageList, '#slice' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.slice(0) }.not_to raise_error
    expect { list.slice(-1) }.not_to raise_error
    expect { list.slice(0, 1) }.not_to raise_error
    expect { list.slice(0..2) }.not_to raise_error
    expect { list.slice(20) }.not_to raise_error
  end
end
