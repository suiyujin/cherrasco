require 'opencv'
require './app/mulyu_robot.rb'
include OpenCV

class ImageAnalyzer
  attr_reader :degree, :distance_m

  INIT_UPLOAD_TIME = '00000000000000'
  PRIVATE_FILE_PATH = "#{File.expand_path(File.dirname(__FILE__)).sub(/app/, 'tmp/images/')}"

  #両マーカーの中心点間の距離(メートル)を設定
  KMarkerInterval = 0.10

  def initialize(previous_upload_time, current_upload_time)
    @previous_upload_time = previous_upload_time
    @current_upload_time = current_upload_time
    #@input_image = CvMat.load("#{File.expand_path(File.dirname(__FILE__))}/opencv/cherrasco/case4.jpg")
    @input_image = CvMat.load("#{File.expand_path(File.dirname(__FILE__)).sub(/app/, 'tmp/images/')}#{current_upload_time}.jpg")
  end

  # 虫が存在するか
  def exist_insect?
    @head_pos, @tail_pos, @enemy_pos = search_chupachaps

    puts "head_pos :  #{@head_pos.x}  #{@head_pos.y}" unless @head_pos.nil?
    puts "tail_pos :  #{@tail_pos.x}  #{@tail_pos.y}" unless @tail_pos.nil?
    puts "enemy_pos : #{@enemy_pos.x}  #{@enemy_pos.y}" unless @enemy_pos.nil?

    (@head_pos.nil? || @tail_pos.nil? || @enemy_pos.nil?) ? false : true
  end

  # ロボットへの命令を作成
  def make_command
    # ロボットが進むべき角度と距離を計算
    bot = MulyuRobot.new(@head_pos, @tail_pos, KMarkerInterval)
    direction, @distance_m = bot.calculateForTurn(@enemy_pos)
    @degree = direction * 180 / Math::PI
    puts @distance_m, @degree
  end

  private

  def search_chupachaps
    head_pos = nil
    tail_pos = nil
    enemy_pos = nil

    background_image = CvMat.load(PRIVATE_FILE_PATH + "background.jpg")
    diff_image = background_image.abs_diff(@input_image).not

    diff_image.save_image(PRIVATE_FILE_PATH + "diff_image#{@current_upload_time}.png")

    # 円の検出
    dp = 1                # 分解能の比率の逆数
    min_dist = 50         # 円同士の距離
    edge_threshold = 20  # エッジの閾値
    vote_threshold = 50   # 小さいほど多くの検出する円の個数が増える
    min_radius = 50      # 今は使ってないけどいずれ
    max_radius = 100      # 今は使ってないけどいずれ
    gray = diff_image.BGR2GRAY
    gray_smooth = gray.smooth(CV_GAUSSIAN)
    match = gray_smooth.hough_circles(
      CV_HOUGH_GRADIENT,
      dp,
      min_dist,
      edge_threshold,
      vote_threshold,
      min_radius,
      max_radius
    )  # todo: dp以外は調整したほうがよさそう


    # 円毎にマーカーかチェック
    match.each_with_index do |circle, index|
      # 円に内接する四角形を切りぬき
      root2 = 2.0**(1.0/2.0)
      center_pos = CvPoint.new(circle[0], circle[1])
      crip_size = CvSize.new(circle[2]*2/root2, circle[2]*2/root2)
      crip_img = @input_image.rect_sub_pix(center_pos, crip_size)

      # 切り抜いた四角形を1pxのhsvに変換
      one_pix_img = crip_img.resize(CvSize.new(1, 1))
      hsv = rgb2hsv(one_pix_img[0][2], one_pix_img[0][1], one_pix_img[0][0])
      # H:0-360, S:0-255, V:0-255

      puts "circle_id : " + index.to_s
      puts hsv
      from = CvPoint.new(circle[0]-circle[2]*2, circle[1]-circle[2]*2)
      to = CvPoint.new(circle[0]+circle[2]*2, circle[1]+circle[2]*2)

      # 赤い丸があったら head_pos に中心点を入れる
      if (((0 <= hsv[0] && hsv[0] < 20) || (340 < hsv[0] && hsv[0] <= 360)) \
          && (50 < hsv[1] && hsv[1] < 240) \
          && (50 < hsv[2]))
        head_pos = center_pos

        gray_smooth.rectangle!(from, to, :color => CvColor::White, :thickness => -1)
      end

      # 青い丸があったら tail_pos に中心点を入れる
      if ((200 < hsv[0] && hsv[0] < 240) \
          && (50 < hsv[1] && hsv[1] < 240) \
          && (50 < hsv[2]))
        tail_pos = center_pos

        gray_smooth.rectangle!(from, to, :color => CvColor::White, :thickness => -1)
      end

      # todo: 色の閾値を調整する
    end
    binarized_image = gray_smooth.threshold(120,255,CV_THRESH_BINARY)
    binarized_image.save_image("#{File.expand_path(File.dirname(__FILE__)).sub(/app/, 'tmp/images/')}/binarized_image#{@current_upload_time}.png")
    enemy_pos = search_insect(binarized_image)

    [head_pos, tail_pos, enemy_pos]
  end

  # 虫の位置を調べる
  def search_insect(cvmat)
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
    if rows.count > 0
      CvPoint.new((cols.max+cols.min)/2,(rows.max+rows.min)/2)
    else
      nil
    end
  end

  def rgb2hsv(red, green, blue)
    min = [red, green, blue].min
    max = [red, green, blue].max
    if max == min then
      sat = 0
      hue = 0
    else
      sat = 255.0 * (max - min) / max
      cr = 1.0 * (max - red) / (max - min)
      cg = 1.0 * (max - green) / (max - min)
      cb = 1.0 * (max - blue) / (max - min)
      case max
      when red
        hue = 60.0 * (cb - cg)
      when green
        hue = 60.0 * (2.0 + cr - cb)
      when blue
        hue = 60.0 * (4.0 + cg - cr)
      end
      hue += 360 if hue < 0
    end
    [hue, sat, max]
  end
end
