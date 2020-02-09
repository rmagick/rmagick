RSpec.describe Magick::ImageList, '#fill' do
  before do
    @list = described_class.new(*FILES[0..9])
    @list2 = described_class.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'works' do
    list = @list.copy
    img = list[0].copy
    expect do
      expect(list.fill(img)).to be_instance_of(described_class)
    end.not_to raise_error
    list.each { |el| expect(img).to be(el) }

    list = @list.copy
    list.fill(img, 0, 3)
    0.upto(2) { |i| expect(list[i]).to be(img) }

    list = @list.copy
    list.fill(img, 4..7)
    4.upto(7) { |i| expect(list[i]).to be(img) }

    list = @list.copy
    list.fill { |i| list[i] = img }
    list.each { |el| expect(img).to be(el) }

    list = @list.copy
    list.fill(0, 3) { |i| list[i] = img }
    0.upto(2) { |i| expect(list[i]).to be(img) }

    expect { list.fill('x', 0) }.to raise_error(ArgumentError)
  end
end
