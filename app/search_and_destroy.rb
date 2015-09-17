require 'bundler/setup'
require 'opencv'
include OpenCV

#両マーカーの中心点間の距離(メートル)を設定
KMarkerInterval = 0.10

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

  attr_accessor :location, :direction, :marker_interval, :meter_per_dot

  def initialize(head_point,tail_point,marker_interval)
    @location = CvPoint.new((head_point.x+tail_point.x)/2,(head_point.y+tail_point.y)/2)
    @direction = Math.atan2(tail_point.y-head_point.y,head_point.x-tail_point.x)
    @marker_interval = marker_interval
    @meter_per_dot = @marker_interval/(Math.hypot(tail_point.x-head_point.x,tail_point.y-head_point.y).round)
  end

  # distination:回転させたい目標地点(CvPoint)  return [目標地点へ向くために必要な角度,目標地点への距離]
  def calculateForTurn(distination)
    dist_direction = Math.atan2(@location.y-distination.y,distination.x-@location.x)

    return dist_direction-@direction, Math.hypot(@location.x-distination.x,@location.y-distination.y)*@meter_per_dot
  end

end

begin
  #background_image = CvMat.load("xxx/xxx.jpg")
  #camera_image = CvMat.load(""yyy/yyy.jpg)
  input_img = CvMat.load("bug_match/case1.jpg")
  marker_img = CvMat.load("markers/red.png")
rescue
  puts '開けませんでした'
  exit
end

#input_img = background_image.abs_diff(camera_image).not

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

black_rows,black_cols = searchObject(gray_smooth)

enemy_center = CvPoint.new((black_cols.max-black_cols.min)/2,(black_rows.max-black_rows.min)/2)

bot = Robot.new(head_point,tail_point,KMarkerInterval)

puts bot.calculateForTurn(enemy_center)
