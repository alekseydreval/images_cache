require 'open-uri'
require 'redis'
require 'pry'

module CloudinaryCache

  CACHE_LIMIT = 2          # CACHE_LIMIT + 1 most popular items
  REDIS       = Redis.new


  def self.included base
    base.class_eval do
      unless base.column_names.include? 'cloudinary_cache'
        throw 'You must add cloudinary_cache:text column to model before using the cache'
      end
      serialize :cloudinary_cache, Hash
    end
  end

  def image_url version = :standard
    original_url = super(version)
    cached_url   = cached_url(version)

    if cached_url
      cached_url
    else
      if popular_enough?
        delay.download_cloudinary_image original_url, version
      end
      original_url
    end
  end

  def popularity
    REDIS.zscore(self.class.name, self.id) || 0
  end

  def increment_popularity
    REDIS.zincrby self.class.name, 1, self.id
  end



  private
  def popular_enough?
    ids = REDIS.zrevrange self.class.name, 0, CACHE_LIMIT
    ids.include? self.id.to_s
  end

  def cached_url version
    self.cloudinary_cache[version]
  end

  def download_cloudinary_image url, version
    file_name  = "#{version}_#{File.basename(URI.parse(url).path)}"
    file_url   = File.join '/images', 'cached', file_name
    file_path  = File.join Rails.root, 'public', file_url

    File.open(file_path, "wb") do |file|
      file << open(url).read
      self.cloudinary_cache[version] = file_url
      self.save
    end
  end

end
