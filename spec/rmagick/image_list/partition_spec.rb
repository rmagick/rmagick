RSpec.describe Magick::ImageList, '#partition' do
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
    a = nil
    n = -1
    expect do
      a = @list.partition do
        n += 1
        (n & 1).zero?
      end
    end.not_to raise_error
    expect(a).to be_instance_of(Array)
    expect(a.size).to eq(2)
    expect(a[0]).to be_instance_of(Magick::ImageList)
    expect(a[1]).to be_instance_of(Magick::ImageList)
    expect(a[0].scene).to eq(4)
    expect(a[0].length).to eq(5)
    expect(a[1].scene).to eq(4)
    expect(a[1].length).to eq(5)
  end
end
