# frozen_string_literal: true

RSpec.describe Magick::ImageList, "#clone" do
  it "works" do
    image_list = described_class.new

    image_list.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    image_list2 = image_list.clone
    expect(image_list).to eq(image_list2)
    expect(image_list2.frozen?).to eq(image_list.frozen?)
    image_list.freeze
    image_list2 = image_list.clone
    expect(image_list2.frozen?).to eq(image_list.frozen?)
  end

  it "accepts the freeze keyword as Object#clone does" do
    object = described_class.new.tap { |list| list << Magick::Image.new(2, 2) }.freeze

    expect(object.clone(freeze: false)).not_to be_frozen
    expect(object.clone(freeze: true)).to be_frozen
  end
end
