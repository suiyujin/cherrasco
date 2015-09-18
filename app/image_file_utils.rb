require 'fileutils'

module ImageFileUtils
  LIMIT_NUM_DATA = 3

  def check_file_limit(image_file_dir, image_file_prefix)
    # tmp/images/内の画像がn個より多い場合、最新のn個を残して破棄
    Dir.chdir(image_file_dir) do
      image_files = Dir.glob(image_file_prefix).sort
      if image_files.size > LIMIT_NUM_DATA
        FileUtils.rm(image_files[0, image_files.size - LIMIT_NUM_DATA])
      end
    end
  end
end
