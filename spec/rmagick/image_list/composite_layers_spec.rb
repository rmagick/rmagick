RSpec.describe Magick::ImageList, '#composite_layers' do
  before do
    @list = Magick::ImageList.new(*FILES[0..9])
    @list2 = Magick::ImageList.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'works' do
    expect { @list.composite_layers(@list2) }.not_to raise_error
    Magick::CompositeOperator.values do |op|
      expect { @list.composite_layers(@list2, op) }.not_to raise_error
    end

    expect { @list.composite_layers(@list2, Magick::ModulusAddCompositeOp, 42) }.to raise_error(ArgumentError)
  end
end
