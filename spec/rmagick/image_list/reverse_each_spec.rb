RSpec.describe Magick::ImageList, '#reverse_each' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect do
      @list.reverse_each { |img| expect(img).to be_instance_of(Magick::Image) }
    end.not_to raise_error
  end
end
