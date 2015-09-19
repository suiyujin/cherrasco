require 'yaml'

class Robot
  DEFAULT_CONFIG_PATH = './config/raspi.yml'

  def initialize(config_path = DEFAULT_CONFIG_PATH)
    conf = YAML.load_file(config_path)
    @command = "ssh -4 -i #{conf['identity_file']} #{conf['user']}@#{conf['host']} -p #{conf['port']} #{conf['program']}"
    @infrared_program = conf['infrared_program']
  end

  def execute(degree, distance_m)
    command = "#{@command} #{degree} #{distance_m} && #{@infrared_program}"
    puts command
    # NOTE: coomand response message when catched an insect
    `#{command}`.chomp.empty? ? false : true
  end
end
