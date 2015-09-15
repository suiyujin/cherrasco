require 'yaml'
require 'mysql2'
require 'redis'
require 'hiredis'

module DBUtils
  LIMIT_NUM_DATA = 3

  def load_config_file
    YAML.load_file('./db/config.yml')
  end

  def mysql_connect
    config = load_config_file
    Mysql2::Client.new(
      :host => config["mysql2"]["host"],
      :username => config["mysql2"]["username"],
      :password => config["mysql2"]["password"],
      :database => config["mysql2"]["database"]
    )
  end

  def redis_connect
    config = load_config_file
    Redis.new(config["hiredis"])
  end

  def check_data_limit(redis)
    # list内のデータがn個より多い場合、最新のn個を残して破棄
    if redis.llen("images").to_i > LIMIT_NUM_DATA
      redis.ltrim("images", 0, LIMIT_NUM_DATA - 1)
    end
  end
end
