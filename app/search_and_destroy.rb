require 'bundler/setup'
require 'opencv'
include OpenCV

def searchObject(cvmat)
  rows = []
  cols = []
  cvmat.rows.times { |i|
    cvmat.cols.times { |j|
      if (cvmat[i,j][0] == 0)
        rows << i
        cols << j
      end
    }
  }
  return rows,cols
end

class Robot
  attr_accessor :location, :direction, :interval
  def initialize(head_point,tail_point,interval)
    @location = CvPoint.new((head_point.x+tail_point.x)/2,(head_point.y+tail_point.y)/2)
    @direction = Math.atan2(tail_point.y-head_point.y,head_point.x-tail_point.x)
    @interval = 
    puts "head: #{head_point.x} #{head_point.y}, tail: #{tail_point.x} #{tail_point.y}"
    puts "location: #{location.x} #{location.y}"
    puts "direction: #{@direction}"
  end

  def radianForTurn(distination)
    dist_direction = Math.atan2(@location.y-distination.y,distination.x-@location.x)
    return dist_direction-@direction
  end

end

begin
  input_img = CvMat.load("bug_match/case1.jpg")
  marker_img = CvMat.load("markers/red.png")
rescue
  puts '開けませんでした'
  exit
end

#diff_image = background_image.abs_diff(camera_image).not
#diff_image = diff_image.threshold()

gray = input_img.BGR2GRAY
gray_smooth = gray.smooth(CV_GAUSSIAN)
match = gray_smooth.hough_circles(CV_HOUGH_GRADIENT, 1, 100, 100, 30)

head_point = CvPoint.new()
tail_point = CvPoint.new()
match.each_with_index do |circle,index|
  break if index>1
  from = CvPoint.new(circle[0] - 1.5*circle[2], circle[1] - 1.5*circle[2])
  to = CvPoint.new(circle[0] + 1.5*circle[2], circle[1] + 1.5* circle[2])
  gray_smooth.rectangle!(from, to, :color => CvColor::White, :thickness => -1)
  if index == 0
    head_point = CvPoint.new(circle[0],circle[1])
  else
    tail_point = CvPoint.new(circle[0],circle[1])
  end
end

gray_smooth = gray_smooth.threshold(30,255,CV_THRESH_BINARY)
rows,cols = searchObject(gray_smooth)

from = CvPoint.new(cols.min,rows.min)
to = CvPoint.new(cols.max,rows.max)
center = CvPoint.new((cols.max-cols.min)/2,(rows.max-rows.min)/2)

bot = Robot.new(head_point,tail_point)

gray_smooth.rectangle!(from,to,:color => CvColor::Black, :thickness => 1)
gray_smooth.save_image("match_image.png")
