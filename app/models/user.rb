class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  has_many :donations
end
