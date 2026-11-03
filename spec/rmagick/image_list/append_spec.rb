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

  it 'keeps the images it links when the list replaces one meanwhile' do
    image = Magick::Image.new(2, 2)
    other = Magick::Image.new(2, 2)
    image_list = described_class.new
    image_list << image << other << other
    replacement = Magick::Image.new(2, 2)
    error = nil
    destroy = lambda do
      image.destroy!
    rescue RuntimeError => e
      error = e.message
    end

    appended = during_call(-> { image_list[0] = replacement }, destroy) { image_list.append(false) }

    expect(error).to eq('object is in use by another fiber')
    expect(image).not_to be_destroyed
    expect(appended.columns).to eq(6)
  end

  it 'keeps the list of an image that another list links while it copies' do
    image = Magick::Image.new(2, 2)
    image_list = described_class.new
    image_list << image << Magick::Image.new(2, 2).freeze
    other = described_class.new
    other << image << Magick::Image.new(2, 2)
    finish = nil

    begin
      appended = during_call(-> { finish = pause_in_call { other.append(false) } }) { image_list.append(false) }
    ensure
      other_appended = finish&.call
    end

    expect(appended.columns).to eq(4)
    expect(other_appended.columns).to eq(4)
  end

  it 'lets a call on one of the images meanwhile see it alone' do
    first, image, last = (0..2).map { |n| Magick::Image.read("#{IMAGES_DIR}/Button_#{n}.gif").first }
    image_list = described_class.new
    image_list << first << image << last
    look = lambda do
      draw = Magick::Draw.new
      draw.composite(0, 0, 0, 0, image, Magick::CopyCompositeOp)
      canvas = Magick::Image.new(image.columns, image.rows)
      draw.draw(canvas)
      [image.changed?, image.thumbnail(2, 2)['Thumb::Document::Pages'], image._dump(0), canvas.export_pixels]
    end
    alone = look.call
    seen = []

    during_call(*Array.new(10) { -> { seen << look.call } }) { image_list.append(false) }

    expect(seen).not_to be_empty
    expect(seen).to all(eq(alone))
  end
end
