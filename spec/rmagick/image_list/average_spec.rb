# frozen_string_literal: true

RSpec.describe Magick::ImageList, "#average" do
  it "works" do
    image_list = described_class.new

    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')

    image = image_list.average
    expect(image).to be_instance_of(Magick::Image)

    expect { image_list.average(1) }.to raise_error(ArgumentError)
  end

  it "keeps the list of an image that another list links meanwhile" do
    image = Magick::Image.new(2, 2)
    image_list = described_class.new
    image_list << image
    other = described_class.new
    other << Magick::Image.new(2, 2) << image
    finish = nil

    begin
      average = during_call(-> { finish = pause_in_call { other.append(false) } }) { image_list.average }
    ensure
      appended = finish&.call
    end

    expect(average.columns).to eq(2)
    expect(appended.columns).to eq(4)
  end
end
