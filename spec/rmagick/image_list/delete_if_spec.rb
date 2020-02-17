RSpec.describe Magick::ImageList, '#delete_if' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 7
    cur = list.cur_image

    list.delete_if { |img| File.basename(img.filename) =~ /5/ }
    expect(list).to be_instance_of(described_class)
    expect(list.length).to eq(9)
    expect(list.cur_image).to be(cur)

    # Delete the current image
    list.delete_if { |img| File.basename(img.filename) =~ /7/ }
    expect(list).to be_instance_of(described_class)
    expect(list.length).to eq(8)
    expect(list.cur_image).to be(list[-1])
  end
end
