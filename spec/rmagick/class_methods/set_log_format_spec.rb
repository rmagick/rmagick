RSpec.describe Magick, '.set_log_format' do
  it 'works' do
    expect { Magick.set_log_format('format %d%e%f') }.not_to raise_error
  end
end
