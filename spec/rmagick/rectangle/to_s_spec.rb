describe Magick::Rectangle, '#to_s' do
  it 'works' do
    rect = Magick::Rectangle.new(10, 20, 30, 40)
    expect(rect.to_s).to eq('width=10, height=20, x=30, y=40')
  end
end
