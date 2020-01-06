RSpec.describe Magick::Image::Info, '#page' do
  it 'works' do
    info = described_class.new

    expect { info.page = '612x792>' }.not_to raise_error
    expect(info.page).to eq('612x792>')
    expect { info.page = nil }.not_to raise_error
    expect(info.page).to be(nil)
  end
end
