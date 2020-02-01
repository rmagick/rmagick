RSpec.describe Magick::ImageList do
  before do
    @list = described_class.new(*FILES[0..9])
    @list2 = described_class.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'does not have certain array methods' do
    expect { @list.assoc }.to raise_error(NoMethodError)
    expect { @list.flatten }.to raise_error(NoMethodError)
    expect { @list.flatten! }.to raise_error(NoMethodError)
    expect { @list.join }.to raise_error(NoMethodError)
    expect { @list.pack }.to raise_error(NoMethodError)
    expect { @list.rassoc }.to raise_error(NoMethodError)
  end

  it 'has certain enumerable methods' do
    expect { @list.detect { true } }.not_to raise_error
    expect do
      @list.each_with_index { |img, _n| expect(img).to be_instance_of(Magick::Image) }
    end.not_to raise_error
    expect { @list.entries }.not_to raise_error
    expect { @list.include?(@list[0]) }.not_to raise_error
    expect { @list.inject(0) { 0 } }.not_to raise_error
    expect { @list.max }.not_to raise_error
    expect { @list.min }.not_to raise_error
    expect { @list.sort }.not_to raise_error
    expect { @list.sort_by(&:signature) }.not_to raise_error
    expect { @list.zip }.not_to raise_error
  end
end
