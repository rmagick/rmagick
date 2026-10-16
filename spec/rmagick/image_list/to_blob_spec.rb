# frozen_string_literal: true

RSpec.describe Magick::ImageList, "#to_blob" do
  it "works" do
    image_list = described_class.new

    image_list.read(IMAGES_DIR + '/Button_0.gif')
    blob = nil
    expect { blob = image_list.to_blob }.not_to raise_error
    image = image_list.from_blob(blob)
    expect(image[0]).to eq(image_list[0])
    expect(image.scene).to eq(1)
  end

  it 'splits the images when the thread is interrupted' do
    cancelled = Class.new(StandardError)
    image_list = described_class.new
    2.times { image_list.new_image(1000, 1000) }
    interrupt(cancelled) do
      image_list.to_blob do |info|
        info.format = 'MIFF'
        info.colorspace = Magick::GRAYColorspace
      end
    end

    Dir.mktmpdir do |dir|
      image_list[0].write(File.join(dir, 'first.miff'))

      expect(File.exist?(File.join(dir, 'first.miff'))).to be(true)
    end
  end
end
