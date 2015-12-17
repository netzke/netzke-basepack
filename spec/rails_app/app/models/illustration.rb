class Illustration < ActiveRecord::Base
  mount_uploader :image, ImageUploader
end
