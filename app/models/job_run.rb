class JobRun < ActiveRecord::Base
  belongs_to :target, polymorphic: true
end
