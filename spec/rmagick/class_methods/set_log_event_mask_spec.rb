# frozen_string_literal: true

RSpec.describe Magick, '.set_log_event_mask' do
  after { described_class.set_log_event_mask('None') }

  it 'works' do
    expect { described_class.set_log_event_mask('Module,Coder') }.not_to raise_error
    expect { described_class.set_log_event_mask('Cache', 'Blob') }.not_to raise_error
    expect { described_class.set_log_event_mask('None') }.not_to raise_error
  end

  it 'raises an error when an event name is invalid' do
    expect { described_class.set_log_event_mask('Bogus') }.to raise_error(ArgumentError, 'invalid log event type: Bogus')
    expect { described_class.set_log_event_mask('Cache,Bogus') }.to raise_error(ArgumentError, 'invalid log event type: Cache,Bogus')
    expect { described_class.set_log_event_mask('Cache', 'Bogus') }.to raise_error(ArgumentError, 'invalid log event type: Bogus')
  end
end
