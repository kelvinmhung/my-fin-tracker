class Expense < ActiveRecord::Base
  belongs_to :user
  attr_accessible :amount, :category, :date, :description
  validates :user_id, presence: true

  monetize :amount_cents
  #default_scope order: 'expenses.date DESC'

end
