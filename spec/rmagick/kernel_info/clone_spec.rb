RSpec.describe Magick::KernelInfo, '#clone' do
  before do
    @kernel = Magick::KernelInfo.new('Octagon')
  end

  it 'works' do
    expect(@kernel.clone).to be_instance_of(Magick::KernelInfo)
    expect(@kernel.clone).not_to be(@kernel)
  end
end
