require 'fileutils'

module ImageFileUtils
  LIMIT_NUM_DATA = 3

  def check_file_limit
    # tmp/images/内の画像がn個より多い場合、最新のn個を残して破棄
    Dir.chdir("./tmp/images/") do
      image_files = Dir.glob("2015*.jpg").sort
      if image_files.size > LIMIT_NUM_DATA
        FileUtils.rm(image_files[0, image_files.size - LIMIT_NUM_DATA])
      end
    end
  end
end
