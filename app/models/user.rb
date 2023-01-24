class User < ApplicationRecord
    has_secure_password
    validates :username, presence: {message: "Se requiere un nombre de usuario"}
    validates :username, uniqueness: {message: "Este nombre de usuario ya ha sido tomado"}
    validates :username, length: {minimum:4, too_short: "El nombre es muy corto. Debe ser mayor a 3 caracteres", 
        maximum: 15, too_long: "El nombre es muy largo. Debe ser menor a 16 caracteres" }

    validates :password, presence: {message: "Se requiere una contraseña"}
    validates :password, length: {minimum:8, too_short: "La contraseña es muy corta. Debe ser mayor a 8 caracteres"}
    has_many :players, dependent: :destroy
    has_many :games, through: :players
    has_one_attached :avatar
end
