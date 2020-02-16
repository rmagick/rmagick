RSpec.describe Magick::ImageList, '#delete_if' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 7
    cur = list.cur_image
    expect do
      list.delete_if { |img| File.basename(img.filename) =~ /5/ }
      expect(list).to be_instance_of(described_class)
      expect(list.length).to eq(9)
      expect(list.cur_image).to be(cur)
    end.not_to raise_error

    # Delete the current image
    expect do
      list.delete_if { |img| File.basename(img.filename) =~ /7/ }
      expect(list).to be_instance_of(described_class)
      expect(list.length).to eq(8)
      expect(list.cur_image).to be(list[-1])
    end.not_to raise_error
  end
end
