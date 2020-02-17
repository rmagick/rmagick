require 'timeout'

RSpec.describe Magick::Image, '#read' do
  describe 'issue #200' do
    before do
      # pid = Process.spawn File.join(SUPPORT_DIR, 'issue_200', 'app.rb'), err: :close, out: :close
      # begin
      #   Timeout.timeout(1) do
      #     _, status = Process.waitpid2 pid
      #   end
      # rescue Timeout::Error
      #   Process.kill('KILL', pid)
      #   _, status = Process.waitpid2 pid
      # end
    end

    it 'not hangs with nil argument' do
      skip
      expect(status).not_to be_signaled
    end

    it 'raise error with nil argument' do
      skip
      expect(status).to be_success
      expect { described_class.read(nil) }.to raise_error(Magick::ImageMagickError, /unable to open image nil/)
    end
  end

  describe 'issue #483' do
    it 'can read PDF file' do
      skip if RUBY_PLATFORM =~ /mswin|mingw/
      expect { described_class.read(File.join(FIXTURE_PATH, 'sample.pdf')) }.not_to raise_error
    end
  end
end
