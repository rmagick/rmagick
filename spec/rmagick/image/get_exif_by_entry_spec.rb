RSpec.describe Magick::Image, '#get_exif_by_entry' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.get_exif_by_entry
      expect(res).to be_instance_of(Array)
    end.not_to raise_error
  end
end
