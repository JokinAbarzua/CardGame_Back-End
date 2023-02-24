# Api CardGame
Se desarrolló el back-end del juego de cartas con Ruby on Rails, utilizando la gem bcrypt para la gestión de las passwords y jwt para la generar y validar los JSON Web Tokens.
## Diagrama de Clases
```mermaid
classDiagram
      Game< -->"*" Player
      Player<-->"*"User
	  Avatar_Attachment "1"-->"1"Avatar_Blob
	  Avatar_Attachment "1"-->"1" User
      class Game{
        +points_us: integer
		+points_them: integer
		+us_count: integer
		+players_count: integer
		+size: integer
		+state: integer
		+number: string
		+deck: string[]
		+deals: integer
		+reset_deck()
		+add_point(team)
		+remove_point(team)
		+is_full?()
		+join(user,team)
		+end_game()
		-find_seat(player,team)
		-set_deck()
      }
	  class User{
		+username: string
		+password_digest : string
		+token: string
		+valid_attribute?()$
		+update_avatar(avatar)
		+logout()
	  }
     class Player{
	     +role: integer
		 +team: integer
		 +hand: string[]
		 +seat: integer
		 +played: string[]
		 +play(card)
		 +discard(card)
		 +deal()
		 -set_role()
		 -set_number()		 
   }
   class Avatar_Attachment{
	   +id: integer
	   +name: string
	   +record_type: string
   }
   link Avatar_Attachment "https://pragmaticstudio.com/tutorials/using-active-storage-in-rails" "Join Table Polimorfica"
   class Avatar_Blob{
	   +id: integer
	   +key: string
	   +filename: string
	   +content_type: string
	   +metadata: string<HashMap>
	   +service_name: string
	   +bytesize: integer
	   +checksum: string
   }
```
## Endpoints
### User
| Ruta | Endpoint | Descripción | Success | Error |
| ---- | -------- | ----------- | ------- | ----- |
|GET /users|index||||
|GET /users|show||||
|POST /users|create||||
|PUT /user|update||||
|DELETE /user|||||
||||||
||||||
||||||
||||||
||||||
||||||