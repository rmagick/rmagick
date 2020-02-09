RSpec.describe Magick::KernelInfo, '#clone' do
  before do
    @kernel = described_class.new('Octagon')
  end

  it 'works' do
    expect(@kernel.clone).to be_instance_of(described_class)
    expect(@kernel.clone).not_to be(@kernel)
  end
end
