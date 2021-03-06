class Page < ActiveRecord::Base
  attr_accessible :description, :thumbnail, :title, :url

  #validates :title, :length => { :minimum => 5 }
  validates :url, :length => { :minimum => 5 }
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
end
