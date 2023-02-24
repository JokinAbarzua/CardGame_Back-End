# Api CardGame
Se desarrolló el back-end del juego de cartas con Ruby on Rails, utilizando la gem bcrypt para la gestión de las passwords y jwt para generar y validar los JSON Web Tokens.
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
<table>
<tr>
<td> Ruta </td> <td> Endpoint </td> <td> Description </td> <td> Success </td> <td> Error </td>
</tr>
<tr>
<td> GET /users </td> 
<td> index </td>  
<td> Muestra todos los usuarios guardados en la base de datos  </td> 	<td>

```json
{
    "status": 200,
    "data": {
        "users": [
            {
                "id": 1,
                "username": "John Doe",
                "password_digest": "$2a$12$1UmwWpYf/XwJ/Vs55DeB0eqEWFELaiJjDviaeq1pORJRnvtj7oSee",
                "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE2NzcyNDcxMzF9.ToCRlp_lJ9nmFU-Ox-fxORXQkWiA96olEjN4kan6e-0",
                "created_at": "2023-02-21T20:30:48.758Z",
                "updated_at": "2023-02-24T07:58:51.568Z"
            },            
        ]
    }
}		
```

</td> 
<td>-</td>
</tr>
<tr>
<td> GET /users/:id </td> 
<td> show </td> 
<td>Muestra los datos del usuario con id igual a la pasada en los parámetros</td> 
<td> 

```json
{
    "status": 200,
    "data": {
        "user": {
            "id": 3,
            "username": "John Doe",
            "password_digest": "$2a$12$wrF5twLOl12HB62.rE.jBO4ovfRpp28Au8TjnryXKmKPmPTCa6uEm",
            "token": "",
            "created_at": "2023-02-22T18:01:42.467Z",
            "updated_at": "2023-02-22T21:47:09.738Z"
        }
    }
}
```
</td> 
<td>

```json
{
    "status": 404,
    "data": {
        "message": "No se ha podido encontrar al usuario de id 3"
    }
}
```

</td>
</tr>
<tr>
<td> POST /users </td> 
<td> create </td> 
<td>  
Crea un usuario en la base de datos con los parámetros pasados en el body de la request
</td> 
<td>

```json
{
    "status": 200,
    "data": {
        "user": {
            "id": 8,
            "username": "John Doe",
            "token": null
        }
    }
}
```
</td> 
<td>
Si el nombre de usuario ya existe en la BD:

```json
{
    "status": 400,
    "data": {
        "message": "Username Este nombre de usuario ya ha sido tomado"
    }
}
```
Si el nombre de usuario es muy corto:

```json
{
    "status": 400,
    "data": {
        "message": "Username El nombre es muy corto. Debe ser mayor a 3 caracteres"
    }
}
```
Si la contraseña es muy corta:

```json
{
    "status": 400,
    "data": {
        "message": "Password La contraseña es muy corta. Debe ser mayor a 8 caracteres"
    }
}
```
</td>
</tr>
<tr>
<td> PUT /user </td> 
<td> update </td> 
<td>  </td> 
<td>  </td> 
<td>  </td>
</tr>
<tr>
<td> DELETE /user </td> 
<td> destroy </td> 
<td>  </td> 
<td>  </td> 
<td>  </td>
</tr>
</table>

### Game
