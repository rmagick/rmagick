RSpec.describe Magick::ImageList, '#partition' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    n = -1

    a = image_list.partition do
      n += 1
      (n & 1).zero?
    end

    expect(a).to be_instance_of(Array)
    expect(a.size).to eq(2)
    expect(a[0]).to be_instance_of(described_class)
    expect(a[1]).to be_instance_of(described_class)
    expect(a[0].scene).to eq(4)
    expect(a[0].length).to eq(5)
    expect(a[1].scene).to eq(4)
    expect(a[1].length).to eq(5)
  end
end
