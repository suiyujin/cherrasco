require 'bundler/setup'
require 'opencv'
include OpenCV

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

def search_chupachaps(input_img_url)
  head_pos = nil
  tail_pos = nil

  begin
    input_img = CvMat.load(input_img_url)
  rescue
    puts '開けませんでした'
    exit
  end


  # 円の検出
  dp = 1                # 分解能の比率の逆数
  min_dist = 100        # 円同士の距離
  edge_threshold = 100  # エッジの閾値
  vote_threshold = 30   # 小さいほど多くの検出する円の個数が増える
  min_radius = 100      # 今は使ってないけどいずれ
  max_radius = 100      # 今は使ってないけどいずれ
  gray = input_img.BGR2GRAY
  gray_smooth = gray.smooth(CV_GAUSSIAN)
  match = gray_smooth.hough_circles(
    CV_HOUGH_GRADIENT,
    dp,
    min_dist,
    edge_threshold,
    vote_threshold
  )  # todo: dp以外は調整したほうがよさそう


  # 円毎にマーカーかチェック
  match.each_with_index do |circle,index|
    # 円に内接する四角形を切りぬき
    route2 = 2.0**(1.0/2.0)
    center_pos = CvPoint.new(circle[0], circle[1])
    crip_size = CvSize.new(circle[2]*2/route2, circle[2]*2/route2)
    crip_img = input_img.rect_sub_pix(center_pos, crip_size)

    # 切り抜いた四角形を1pxのhsvに変換
    one_pix_img = crip_img.resize(CvSize.new(1, 1))
    hsv = rgb2hsv(one_pix_img[0][2], one_pix_img[0][1], one_pix_img[0][0])
      # H:0-360, S:0-255, V:0-255

    # 赤い丸があったら head_pos に中心点を入れる
    if (((0 <= hsv[0] && hsv[0] < 20) || (340 < hsv[0] && hsv[0] <= 360)) \
       && (170 < hsv[1] && hsv[1] < 255) \
       && (80 < hsv[2] && hsv[2] < 200))
      head_pos = center_pos
    end

    # 青い丸があったら tail_pos に中心点を入れる
    if ((200 < hsv[0] && hsv[0] < 240) \
       && (170 < hsv[1] && hsv[1] < 240) \
       && (80 < hsv[2] && hsv[2] < 200))
      tail_pos = center_pos
    end

    # todo: 色の閾値を調整する
  end

  return [head_pos, tail_pos]
end

puts search_chupachaps("cherrasco/case1.png")
