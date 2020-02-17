# ensure methods detect destroyed images
RSpec.describe Magick::Image, '#destroy' do
  it 'works' do
    image = described_class.new(20, 20)
    methods = described_class.instance_methods(false).sort
    methods -= %i[__display__ destroy! destroyed? inspect cur_image marshal_load]

    expect(image.destroyed?).to eq(false)
    image.destroy!
    expect(image.destroyed?).to eq(true)
    expect { image.check_destroyed }.to raise_error(Magick::DestroyedImageError)

    methods.each do |method|
      arity = image.method(method).arity
      method = method.to_s

      if method == '[]='
        expect { image['foo'] = 1 }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'difference'
        other = described_class.new(20, 20)
        expect { image.difference(other) }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'channel_entropy' && IM_VERSION < Gem::Version.new('6.9')
        expect { image.channel_entropy }.to raise_error(NotImplementedError)
      elsif method == 'get_iptc_dataset'
        expect { image.get_iptc_dataset('x') }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'profile!'
        expect { image.profile!('x', 'y') }.to raise_error(Magick::DestroyedImageError)
      elsif /=\Z/.match(method)
        expect { image.send(method, 1) }.to raise_error(Magick::DestroyedImageError)
      elsif arity.zero?
        expect { image.send(method) }.to raise_error(Magick::DestroyedImageError)
      elsif arity < 0
        args = (1..-arity).to_a
        expect { image.send(method, *args) }.to raise_error(Magick::DestroyedImageError)
      elsif arity > 0
        args = (1..arity).to_a
        expect { image.send(method, *args) }.to raise_error(Magick::DestroyedImageError)
      else
        # Don't know how to test!
        flunk("don't know how to test method #{method}")
      end
    end
  end
end
