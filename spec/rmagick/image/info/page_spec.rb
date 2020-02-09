RSpec.describe Magick::Image::Info, '#page' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.page = '612x792>' }.not_to raise_error
    expect(@info.page).to eq('612x792>')
    expect { @info.page = nil }.not_to raise_error
    expect(@info.page).to be(nil)
  end
end
