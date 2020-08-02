RSpec.describe Magick::Image, '#new' do
  it 'works Call yield when there is a block argument (issue 699)' do
    self_obj = nil
    yield_obj = nil

    # call instance_eval
    described_class.new(20, 20) do
      self_obj = self
    end
    expect(self_obj).to be_instance_of(Magick::Image::Info)

    # call yield
    described_class.new(20, 20) do |e|
      yield_obj = e
      self_obj = self
    end
    expect(yield_obj).to be_instance_of(Magick::Image::Info)
    expect(self_obj).to eq(self)

    # Able to write in the following manner by calling in yield
    #
    # @background_color = 'red'
    # image = described_class.new(20, 20) { |e| e.background_color = @background_color }
    # expect(image.background_color).to eq('red')
  end
end
