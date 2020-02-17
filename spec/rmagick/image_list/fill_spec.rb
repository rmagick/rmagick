RSpec.describe Magick::ImageList, '#fill' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list2 = list.copy
    image = list[0].copy

    expect(list2.fill(image)).to be_instance_of(described_class)

    list2.each { |el| expect(image).to be(el) }

    list2 = list.copy
    list2.fill(image, 0, 3)
    0.upto(2) { |i| expect(list2[i]).to be(image) }

    list2 = list.copy
    list2.fill(image, 4..7)
    4.upto(7) { |i| expect(list2[i]).to be(image) }

    list2 = list.copy
    list2.fill { |i| list2[i] = image }
    list2.each { |el| expect(image).to be(el) }

    list2 = list.copy
    list2.fill(0, 3) { |i| list2[i] = image }
    0.upto(2) { |i| expect(list2[i]).to be(image) }

    expect { list2.fill('x', 0) }.to raise_error(ArgumentError)
  end
end
