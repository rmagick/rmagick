RSpec.describe Magick, '.limit_resources' do
  it 'works' do
    cur = new = nil

    expect { cur = Magick.limit_resource(:memory, 500) }.not_to raise_error
    expect(cur).to be_kind_of(Integer)
    expect(cur > 1024**2).to be(true)
    expect { new = Magick.limit_resource('memory') }.not_to raise_error
    expect(new).to eq(500)
    Magick.limit_resource(:memory, cur)

    expect { cur = Magick.limit_resource(:map, 3500) }.not_to raise_error
    expect(cur).to be_kind_of(Integer)
    expect(cur > 1024**2).to be(true)
    expect { new = Magick.limit_resource('map') }.not_to raise_error
    expect(new).to eq(3500)
    Magick.limit_resource(:map, cur)

    expect { cur = Magick.limit_resource(:disk, 3 * 1024 * 1024 * 1024) }.not_to raise_error
    expect(cur).to be_kind_of(Integer)
    expect(cur > 1024**2).to be(true)
    expect { new = Magick.limit_resource('disk') }.not_to raise_error
    expect(new).to eq(3_221_225_472)
    Magick.limit_resource(:disk, cur)

    expect { cur = Magick.limit_resource(:file, 500) }.not_to raise_error
    expect(cur).to be_kind_of(Integer)
    expect(cur > 100).to be(true)
    expect { new = Magick.limit_resource('file') }.not_to raise_error
    expect(new).to eq(500)
    Magick.limit_resource(:file, cur)

    expect { cur = Magick.limit_resource(:time, 300) }.not_to raise_error
    expect(cur).to be_kind_of(Integer)
    expect(cur > 300).to be(true)
    expect { new = Magick.limit_resource('time') }.not_to raise_error
    expect(new).to eq(300)
    Magick.limit_resource(:time, cur)

    expect { Magick.limit_resource(:xxx) }.to raise_error(ArgumentError)
    expect { Magick.limit_resource('xxx') }.to raise_error(ArgumentError)
    expect { Magick.limit_resource('map', 3500, 2) }.to raise_error(ArgumentError)
    expect { Magick.limit_resource }.to raise_error(ArgumentError)
  end
end
