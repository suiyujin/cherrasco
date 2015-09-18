class Robot
  attr_reader :executed_flag

  def initialize
    @executed_flag = false
  end

  def execute(command)
    p "command : #{command}"
    # command通りにロボットを動かす

    @executed_flag = true
  end

  # 虫を捕まえたか
  def catch_insect?
    # boolを返す
    true
  end
end
