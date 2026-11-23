# frozen_string_literal: true

RSpec.describe Magick::Image::View::Rows, '#[]' do
  it 'clips start and length to the end of the view' do
    view = Magick::Image.new(10, 10).view(0, 0, 10, 10)

    expect(view[2, 9][].size).to eq(80)
    expect(view[0, 20][].size).to eq(100)
    expect(view[-3, 5][].size).to eq(30)
    expect(view[10, 1][].size).to eq(0)
    expect(view[0][2, 9].size).to eq(8)
    expect(view[0][0, 20].size).to eq(10)
    expect(view[0][-3, 5].size).to eq(3)
    expect(view[0][10, 1].size).to eq(0)
  end

  it 'raises IndexError for columns outside the view' do
    view = Magick::Image.new(10, 10).view(0, 0, 10, 10)

    expect { view[0][11, 1] }.to raise_error(IndexError)
    expect { view[0][-20, 2] }.to raise_error(IndexError)
    expect { view[0][2, -1] }.to raise_error(IndexError)
    expect { view[0][[10]] }.to raise_error(IndexError)
    expect { view[0][[-11]] }.to raise_error(IndexError, 'index [-11] out of range')
    expect { view[[-11]][0] }.to raise_error(IndexError)
  end

  it 'treats three or more integers as a list of indexes' do
    view = Magick::Image.new(10, 10).view(0, 0, 10, 10)

    expect(view[1, 2, 3][0].size).to eq(3)
    expect(view[0][1, 2, 3].size).to eq(3)
  end

  it 'uses the truncated size of a fractional view' do
    view = Magick::Image.new(4, 4).view(0, 0, 2.5, 2)

    expect(view[0][].size).to eq(2)
    expect { view[0][2] }.to raise_error(IndexError)
  end

  it 'reads the same rows each time' do
    view = Magick::Image.new(10, 10).view(0, 0, 10, 10)

    rows = view[[1, 5]]
    expect(rows[0].size).to eq(2)
    expect(rows[0].size).to eq(2)

    rows = view[0, 2]
    expect(rows[0].size).to eq(2)
    expect(rows[1].size).to eq(2)
  end
end
