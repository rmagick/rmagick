RSpec.describe Magick::ImageList, "#new_image" do
  it "works" do
    ilist = described_class.new

    ilist.new_image(20, 20)

    expect(ilist.length).to eq(1)
    expect(ilist.scene).to eq(0)
    ilist.new_image(20, 20, Magick::HatchFill.new('black'))
    expect(ilist.length).to eq(2)
    expect(ilist.scene).to eq(1)
    ilist.new_image(20, 20) { self.background_color = 'red' }
    expect(ilist.length).to eq(3)
    expect(ilist.scene).to eq(2)
  end
end
