require 'bundler/setup'
require 'opencv'

include OpenCV

begin
  input_img1 = CvMat.load("img_0.png")
  input_img2 = CvMat.load("img_1.png")
rescue
  puts '開けませんでした'
  exit
end
diff_img = input_img1 - input_img2

diff_img.save_image("diff_image.png")
