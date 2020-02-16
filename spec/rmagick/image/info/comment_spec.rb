RSpec.describe Magick::Image::Info, '#comment' do
  it 'works' do
    info = described_class.new

    expect { info.comment = 'comment' }.not_to raise_error
    expect(info.comment).to eq('comment')
  end
end
