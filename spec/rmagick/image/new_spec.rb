RSpec.describe Magick::Image, '#new' do
  it 'works Call yield when there is a block argument (issue 699)' do
    self_obj = nil
    yield_obj = nil

    described_class.new(20, 20) do |options|
      yield_obj = options
      self_obj = self
    end

    expect(yield_obj).to be_instance_of(Magick::Image::Info)
    expect(self_obj).to eq(self)
  end

  it 'persists configuration from block argument' do
    image = described_class.new(100, 100) do |info|
      info.colorspace = Magick::LabColorspace
    end
    expect(image.colorspace).to eq(Magick::LabColorspace)
  end
end
