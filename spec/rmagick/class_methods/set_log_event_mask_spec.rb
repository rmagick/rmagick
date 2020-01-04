RSpec.describe Magick, '.set_log_event_mask' do
  it 'works' do
    expect { Magick.set_log_event_mask('Module,Coder') }.not_to raise_error
    expect { Magick.set_log_event_mask('None') }.not_to raise_error
  end
end
