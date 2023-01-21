class User < ApplicationRecord
    has_secure_password
    validates :username, presence: true, uniqueness: true, length: {minimum:4, maximum: 15}     
    validates :password, presence: true, length: {minimum: 8}
    has_many :players, dependent: :destroy
    has_many :games, through: :players
end
