RSpec.describe Magick::Image, '#export_pixels' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.export_pixels
      expect(res).to be_instance_of(Array)
      expect(res.length).to eq(@img.columns * @img.rows * 'RGB'.length)
      res.each do |p|
        expect(p).to be_kind_of(Integer)
      end
    end.not_to raise_error
    expect { @img.export_pixels(0) }.not_to raise_error
    expect { @img.export_pixels(0, 0) }.not_to raise_error
    expect { @img.export_pixels(0, 0, 10) }.not_to raise_error
    expect { @img.export_pixels(0, 0, 10, 10) }.not_to raise_error
    expect do
      res = @img.export_pixels(0, 0, 10, 10, 'RGBA')
      expect(res.length).to eq(10 * 10 * 'RGBA'.length)
    end.not_to raise_error
    expect do
      res = @img.export_pixels(0, 0, 10, 10, 'I')
      expect(res.length).to eq(10 * 10 * 'I'.length)
    end.not_to raise_error

    # too many arguments
    expect { @img.export_pixels(0, 0, 10, 10, 'I', 2) }.to raise_error(ArgumentError)
  end
end
