# ensure methods detect destroyed images
RSpec.describe Magick::Image, '#destroy' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    methods = described_class.instance_methods(false).sort
    methods -= %i[__display__ destroy! destroyed? inspect cur_image marshal_load]

    expect(@img.destroyed?).to eq(false)
    @img.destroy!
    expect(@img.destroyed?).to eq(true)
    expect { @img.check_destroyed }.to raise_error(Magick::DestroyedImageError)

    methods.each do |method|
      arity = @img.method(method).arity
      method = method.to_s

      if method == '[]='
        expect { @img['foo'] = 1 }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'difference'
        other = described_class.new(20, 20)
        expect { @img.difference(other) }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'channel_entropy' && IM_VERSION < Gem::Version.new('6.9')
        expect { @img.channel_entropy }.to raise_error(NotImplementedError)
      elsif method == 'get_iptc_dataset'
        expect { @img.get_iptc_dataset('x') }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'profile!'
        expect { @img.profile!('x', 'y') }.to raise_error(Magick::DestroyedImageError)
      elsif /=\Z/.match(method)
        expect { @img.send(method, 1) }.to raise_error(Magick::DestroyedImageError)
      elsif arity.zero?
        expect { @img.send(method) }.to raise_error(Magick::DestroyedImageError)
      elsif arity < 0
        args = (1..-arity).to_a
        expect { @img.send(method, *args) }.to raise_error(Magick::DestroyedImageError)
      elsif arity > 0
        args = (1..arity).to_a
        expect { @img.send(method, *args) }.to raise_error(Magick::DestroyedImageError)
      else
        # Don't know how to test!
        flunk("don't know how to test method #{method}")
      end
    end
  end
end
