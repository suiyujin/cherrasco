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
    Mysql2::Client.new(config["mysql2"])
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
