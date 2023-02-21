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
    has_one_attached :avatar, dependent: :destroy
    before_destroy do  #para que al momento de eliminar el usuarrio se elimine su avatar. No funcionaba con dependent: :destroy ni :purge
      self.avatar.purge
    end

    def self.valid_attribute?(attr, value, error)
        mock = self.new(attr => value)
        if mock.valid?
            return true
        else            
            error.concat(mock.errors[attr].to_s)
            return !mock.errors.has_key?(attr)          
        end
      end    

    def update_avatar(avatar)
      if self.avatar.attached?
          self.avatar.purge
      end
      return self.update_attribute("avatar", avatar)        
    end

    def logout
      self.token = ""
    end    
end
