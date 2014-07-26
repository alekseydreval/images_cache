require 'rails_helper'
require 'cloudinary_cache'
require 'pry'

describe CloudinaryCache do

  before(:all) do
    DatabaseCleaner.clean
    CloudinaryCache.const_get(:REDIS).flushdb
    3.times { create(:product) }
  end

  def set_popular_range_to n
    CloudinaryCache.const_set :CACHE_LIMIT, n
  end

  def increase_popularity model, n
    n.times do
      model.increment_popularity
    end
  end

  it 'caches image if the model is popular' do
    set_popular_range_to 1
    
    product_a, product_b, product_c = Product.all[0..2]

    increase_popularity product_a, 3
    increase_popularity product_b, 2
    increase_popularity product_c, 1

    # First call to image_url
    [product_a, product_b, product_c].each do |p| 
      p.image_url(:standard).should_not =~ /images\/cached/ 
    end

    # Subsequent calls
    product_a.image_url(:standard).should =~ /images\/cached/
    product_b.image_url(:standard).should =~ /images\/cached/
    product_c.image_url(:standard).should_not =~ /images\/cached/
  end

end
