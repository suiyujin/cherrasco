class MulyuRobot
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
