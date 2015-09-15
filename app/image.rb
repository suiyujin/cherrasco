class Image

  attr_reader :upload_time, :image_binary

  def initialize(now_strftime, image_binary)
    @upload_time = now_strftime
    @image_binary = image_binary
  end
end
