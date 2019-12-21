RSpec.describe Magick::Image, '#resize_to_fit' do
  it 'works with two arguments' do
    img = Magick::Image.new(200, 250)
    res = nil
    expect { res = img.resize_to_fit(50, 50) }.not_to raise_error
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(img)
    expect(res.columns).to eq(40)
    expect(res.rows).to eq(50)
  end

  it 'works with one argument' do
    img = Magick::Image.new(200, 300)
    changed = img.resize_to_fit(100)
    expect(changed).to be_instance_of(Magick::Image)
    expect(changed).not_to be(img)
    expect(changed.columns).to eq(67)
    expect(changed.rows).to eq(100)
  end
end
