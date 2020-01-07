RSpec.describe Magick::Image::Info, '#comment' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.comment = 'comment' }.not_to raise_error
    expect(@info.comment).to eq('comment')
  end
end
