# frozen_string_literal: true

RSpec.describe Magick::Image, '#read' do
  describe 'issue #200' do
    it 'raise error with nil argument' do
      expect { described_class.read(nil) }.to raise_error(ArgumentError)
    end
  end

  describe 'issue #483' do
    # The newer Ghostscript might not be worked with old ImageMagick.
    it 'can read PDF file', unless: -> { ENV.fetch('RMAGICK_SKIP_GHOSTSCRIPT_TEST', nil) } do
      expect { described_class.read(File.join(FIXTURE_PATH, 'sample.pdf')) }.not_to raise_error
    end

    it "keeps a SIGCHLD trap that is set while an image is read", if: RUBY_PLATFORM.match?(/darwin|freebsd/) do
      calls = 0
      previous = Signal.trap("CHLD", "SYSTEM_DEFAULT")
      begin
        finish = pause_in_call { described_class.read(FLOWER_HAT) }
        Signal.trap("CHLD") { calls += 1 }
        expect(finish.call.length).to eq(1)

        Process.kill("CHLD", Process.pid)
        sleep(0.05)
        expect(calls).to eq(1)
      ensure
        Signal.trap("CHLD", previous)
      end
    end

    # On Ruby 3.2, putting back the nil that trap returns during a read makes Ruby reap every child.
    it "restores the SIGCHLD handler when a trap made during a read is put back", if: RUBY_PLATFORM.match?(/darwin|freebsd/) && Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3") do
      previous = Signal.trap("CHLD", "SYSTEM_DEFAULT")
      begin
        finish = pause_in_call { described_class.read(FLOWER_HAT) }
        old = Signal.trap("CHLD", "DEFAULT")
        Signal.trap("CHLD", old)
        expect(finish.call.length).to eq(1)

        expect { Process.wait(Process.spawn("true")) }.not_to raise_error
      ensure
        Signal.trap("CHLD", previous)
      end
    end
  end

  it 'raises an error when the filename contains a null byte' do
    expect { described_class.read("#{IMAGES_DIR}/Button_0.gif\0.png") }.to raise_error(ArgumentError)
  end

  it 'sync Image::Info' do
    result = described_class.read(IMAGES_DIR + '/Button_0.gif') do |options|
      options.colorspace = Magick::LabColorspace
    end
    expect(result.first.colorspace).to eq(Magick::LabColorspace)
  end

  it "frees the images it read when one of its calls is interrupted" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "image.miff")
      source = described_class.new(64, 64)
      source.write(path)
      source.destroy!
      GC.start
      baseline = Magick.resource_usage(:memory)
      calls = interrupt_each_call(Class.new(StandardError)) do
        described_class.read(path) { |options| options.colorspace = Magick::GRAYColorspace }
      end
      3.times { GC.start }

      expect(calls).to be_positive
      expect(Magick.resource_usage(:memory)).to be <= baseline
    end
  end
end
