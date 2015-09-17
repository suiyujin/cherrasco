class ImageAnalyzer
  INIT_UPLOAD_TIME = '00000000000000'

  def initialize(previous_upload_time, current_upload_time)
    @previous_upload_time = previous_upload_time
    @current_upload_time = current_upload_time
  end

  # 虫が存在するか
  def exist_insect?
    check_insect_info

    # boolを返す
    true
  end

  # ロボットへの命令を作成
  def make_command
    check_robot_info

    # ロボットが進むべき角度と距離を計算

    # ロボットへの命令
    {
      angle: 30,
      distance_cm: 100
    }
  end

  private

  # 虫の位置を検出
  def check_insect_info
  end

  # ロボットの位置と向きを検出
  def check_robot_info
  end
end
