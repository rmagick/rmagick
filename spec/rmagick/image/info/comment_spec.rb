RSpec.describe Magick::Image::Info, '#comment' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.comment = 'comment' }.not_to raise_error
    expect(@info.comment).to eq('comment')
  end
end
