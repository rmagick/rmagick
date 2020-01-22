describe Magick, '.trace_proc' do
  after do
    Magick.trace_proc = nil
  end

  it 'works' do
    Magick.trace_proc = proc do |which, description, id, method|
      expect(which).to eq(:c)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:initialize)
    end
    img = Magick::Image.new(20, 20)

    Magick.trace_proc = proc do |which, description, id, method|
      expect(which).to eq(:d)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:"destroy!")
    end
    img.destroy!
  end
end
