describe Magick::Image, '#liquid_rescale' do
  it 'works' do
    skip "delegate library support not built-in ''"
    img = described_class.new(20, 20)

    begin
      img.liquid_rescale(15, 15)
    rescue NotImplementedError
      puts 'liquid_rescale not implemented.'
      return
    end

    res = nil
    expect do
      res = img.liquid_rescale(15, 15)
    end.not_to raise_error
    expect(res.columns).to eq(15)
    expect(res.rows).to eq(15)
    expect { img.liquid_rescale(15, 15, 0, 0) }.not_to raise_error
    expect { img.liquid_rescale(15) }.to raise_error(ArgumentError)
    expect { img.liquid_rescale(15, 15, 0, 0, 0) }.to raise_error(ArgumentError)
    expect { img.liquid_rescale([], 15) }.to raise_error(TypeError)
    expect { img.liquid_rescale(15, []) }.to raise_error(TypeError)
    expect { img.liquid_rescale(15, 15, []) }.to raise_error(TypeError)
    expect { img.liquid_rescale(15, 15, 0, []) }.to raise_error(TypeError)
  end
end
