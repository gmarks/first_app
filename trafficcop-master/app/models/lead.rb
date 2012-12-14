class Lead < ActiveRecord::Base
  validates :agent_id, :consumer_first_name, :consumer_last_name, :consumer_email, :presence => true
  validates_format_of :consumer_email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validate :name_is_real

    def name_is_real
      if consumer_first_name == "Your Name (Required)"
        logger.debug ""
        errors.add(:consumer_first_name)
      end
    end

end
