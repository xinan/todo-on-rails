class Todo < ActiveRecord::Base
  acts_as_taggable
  validates :title, presence: true
  default_scope { order(created_at: :desc) }
  scope :active, -> { where(completed: false) }
  scope :done, -> { where(completed: true) }
end
