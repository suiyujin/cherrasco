class Image

  attr_reader :key, :image_binary

  def initialize(now_strftime, image_binary)
    @key = now_strftime
    @image_binary = image_binary
  end
end
