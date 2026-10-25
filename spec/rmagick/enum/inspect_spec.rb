# frozen_string_literal: true

RSpec.describe Magick::Enum, '#inspect' do
  it 'works' do
    expect(Magick::RGBColorspace.inspect).to match(/\ARGBColorspace=\d+\z/)
  end

  # Regression: an Enum made with allocate but never initialized has no symbol,
  # so inspect passed the NULL from rb_id2name(0) to snprintf's %s.
  it 'does not pass NULL to snprintf for an Enum created with allocate' do
    enum = Magick::ColorspaceType.allocate
    expect(enum.inspect).to eq('=0')
  end
end
