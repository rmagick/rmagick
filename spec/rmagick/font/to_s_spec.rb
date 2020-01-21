describe Magick::Font, '#to_s' do
  it 'works' do
    font = Magick.fonts[0]
    expect(font.to_s).to match(/^name=.+, description=.+, family=.+, style=.+, stretch=.+, weight=.+, encoding=.*, foundry=.*, format=.*$/)
  end
end
