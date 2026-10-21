# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Magick::ImageList, '#<<' do
  it 'allows appending identical instances more than once' do
    image = Magick::Image.new(1, 1)
    image_list = described_class.new

    image_list << image << image

    result = image_list.append(false)
    expect(result.columns).to eq(2)
    expect(result.rows).to eq(1)
  end

  it 'keeps the clones of repeated instances alive until the list has been used' do
    image = Magick::Image.new(1, 1)
    image_list = described_class.new
    10.times { image_list << image }

    GC.stress = true
    begin
      result = image_list.append(false)
    ensure
      GC.stress = false
    end

    expect(result.columns).to eq(10)
  end

  it 'raises instead of destroying an image of the list while the call uses it' do
    image_list = described_class.new
    image_list << Magick::Image.new(1, 1) << Magick::Image.new(1, 1)

    expect { during_call(-> { image_list[1].destroy! }) { image_list.append(false) } }.to raise_error(RuntimeError, 'object is in use by another fiber')
    expect(image_list[1].destroyed?).to be(false)
  end

  it 'unlinks the images that a call of another thread linked in the child of a fork', unless: Gem.win_platform? do
    image_list = described_class.new
    3.times { image_list << Magick::Image.new(1, 1) }
    called = Queue.new
    resume = Queue.new
    thread = Thread.new { during_call(-> { called << true and resume.pop }) { image_list.append(false) } }
    called.pop
    reader, writer = IO.pipe
    pid = fork do
      reader.close
      Dir.mktmpdir do |dir|
        image_list[0].write(File.join(dir, 'first.gif'))
        writer.write(Dir.children(dir).sort.join(','))
      end
    ensure
      writer.close
      Process.kill(:KILL, Process.pid)
    end
    writer.close
    Process.wait(pid)
    resume << true
    thread.join

    expect(reader.read).to eq('first.gif')
  ensure
    reader&.close
  end

  it "works" do
    image_list = described_class.new
    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')

    image = image_list.append(true)
    expect(image).to be_instance_of(Magick::Image)

    image = image_list.append(false)
    expect(image).to be_instance_of(Magick::Image)

    expect { image_list.append }.to raise_error(ArgumentError)
    expect { image_list.append(true, 1) }.to raise_error(ArgumentError)
  end
end
