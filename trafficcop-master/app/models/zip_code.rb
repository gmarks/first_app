class ZipCode < ActiveRecord::Base

  validates_uniqueness_of :zip_code
  
  has_many :buyer_leads_zip_codes
  has_many :parties, :through => :buyer_leads_zip_codes

  
end
