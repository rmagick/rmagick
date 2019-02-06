require 'timeout'

RSpec.describe Magick::Image, '#read' do
  describe 'issue #200' do
    before do
      # pid = Process.spawn File.join(SUPPORT_DIR, 'issue_200', 'app.rb'), err: :close, out: :close
      # begin
      #   Timeout.timeout(1) do
      #     _, @status = Process.waitpid2 pid
      #   end
      # rescue Timeout::Error
      #   Process.kill('KILL', pid)
      #   _, @status = Process.waitpid2 pid
      # end
    end

    it 'not hangs with nil argument' do
      skip
      expect(@status.signaled?).to be_falsey
    end

    it 'raise error with nil argument' do
      skip
      expect(@status.success?).to be_truthy
      expect { Magick::Image.read(nil) }.to raise_error(Magick::ImageMagickError, /unable to open image nil/)
    end
  end
end
