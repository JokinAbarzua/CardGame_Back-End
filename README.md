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
Para todas las request (excepto "create" y "login") es necesario enviar el JWT que autoriza al portador en el header como authorization bearer.<br/>Cuando se recibe una request sin JWT o estando éste caducado se responde:
```json
{
    "status": 401,
    "data": {
        "message": "Su token ha expirado"
    }
}
```
### Auth
<table>
<tr>
<td> Ruta </td> <td> Endpoint </td> <td> Descripcion </td> <td> Success </td> <td> Error </td>
</tr>  
<tr>
<td> POST /auth/login </td> 
<td>  login </td>  
<td> Valida usuario y contraseña y genera un JWT<br/>Body params: Username, password </td> 
<td> 

```json
{
    "status": 200,
    "data": {
        "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMCwiZXhwIjoxNjc3MzYyNzUzfQ.vtVXxuqmD4ZKsnio0UqrJCYWc8-Xy7NLoXjaTBpJsYY",
        "user": {
            "id": 10,
            "username": "JohnDoe"
        }
    }
}
```
</td> 
<td> 

```json
{
    "status": 403,
    "data": {
        "message": "Usuario o Contraseña Invalidos"
    }
}
```
</td>
</tr>
<tr>
<td> POST /auth/logout </td> 
<td> logout </td>  
<td> Elimina el token de la sesión actual </td> 
<td> 

```json
{
    "status": 200,
    "data": {
        "message": "Que vuelvas pronto :)"
    }
}
```
</td> 
<td> - </td>
</tr>
</table>

### User
<table>
<tr>
<td> Ruta </td> <td> Endpoint </td> <td> Descripción </td> <td> Success </td> <td> Error </td>
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
<td> Actualiza los datos del usuario que envía la request con los parámetros del body</td> 
<td>

```json
{
    "status": 200,
    "data": {
        "token": "",
        "user": {
            "username": "John Doe",
            "id": 8
        }
    }
}
```

</td> 
<td> 
Presenta los mismos mensajes de error de las validaciones en el endpoint create

```json
{
    "status": 400,
    "data": {
        "message": ""
    }
}
```
</td>
</tr>
<tr>
<td> DELETE /user </td> 
<td> destroy </td> 
<td>  Elimina de la base de datos al usuario que envía la request </td> 
<td>  

```json
{
    "status": 200,
    "data": {
        "message": "Usuario Eliminado con Exito"
    }
}
```

</td> 
<td> 

```json
{
	"status": 400, 
	"data": {
		"message": ""
	}
}
```

</td>
</tr>
</table>

### Game
<table>
<tr>
<td> Ruta </td> <td> Endpoint </td> <td> Descripción </td> <td> Success </td> <td> Error </td>
</tr>
<tr>
<td>GET /games  </td> 
<td> index </td> 
<td> Muestra todo los juegos en los que se encuentra el usuario que hace la request </td> 
<td> 

```json
{
    "status": 200,
    "data": {
        "games": [
            {
                "points_us": 0,
                "points_them": 0,
                "size": 2,
                "state": "started",
                "number": "JohnDoe#298",
                "created_at": "2023-02-22T18:03:00.217Z"
            },       
        ]
    }
}
```

 </td> 
<td> - </td>
</tr>
<tr>
<td> POST /game </td> 
<td> create </td> 
<td>  Crea en la base de datos un nuevo juego de tamaño igual al pasado en los parámetros del body</td> 
<td>

```json
{
    "status": 200,
    "data": {
        "game": {
            "points_us": 0,
            "points_them": 0,
            "players_count": 1,
            "size": 4,
            "state": "waiting",
            "number": "JohnDoe#36",
            "deals": 0,
            "created_at": "2023-02-25T02:31:21.464Z",
            "players": [
                {
                    "seat": 0,
                    "role": "admin",
                    "team": "us",
                    "played": [],
                    "user": {
                        "username": "elfran"
                    }
                }
            ]
        },
        "hand": []
    }
}
```
</td> 
<td>  

```json
{
	"status": 500, 
	"data": {
		"message": "Error at DataBase update"
	}
}
```
</td>
</tr>
<tr>
<td> POST /game/join</td> 
<td> join </td> 
<td> Ingresa a una partida al usuario que hace la request<br/>Body params: Team, Number </td> 
<td>  

```json
{
    "status": 200,
    "data": {
        "game": {
            "players_count": 2,
            "points_us": 0,
            "points_them": 0,
            "size": 4,
            "state": "waiting",
            "number": "JohnDoe#36",
            "deals": 0,
            "created_at": "2023-02-25T02:31:21.464Z",
            "players": [
                {
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "played": [],
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "played": [],
                    "user": {
                        "username": "Richard Roe"
                    }
                }
            ]
        },
        "hand": []
    }
}
```

</td> 
<td>
Si el usuario ya se encuentra en la partida

```json
{
    "status": 400,
    "data": {
        "message": "El usuario ya se encuentra en la partida"
    }
}
```
Si el equipo deseado ya esta lleno

```json
{
    "status": 400,
    "data": {
        "message": "El equipo \"<nosotros | ellos>\" ya está lleno"
    }
}
```

Si el juego ya está lleno

```json
{
    "status": 400,
    "data": {
        "message": "El juego ya esta lleno"
    }
}
```
</td>
</tr>
<tr>
<td>POST /game/deal</td> 
<td> deal </td> 
<td> Mezcla el mazo y reparte 3 cartas a cada jugador <br/>Body params: GameNumber</td> 
<td> 

```json
{
    "status": 200,
    "data": {
        "game": {
            "state": "started",
            "deals": 1,
            "points_us": 0,
            "points_them": 0,
            "players_count": 2,
            "size": 2,
            "number": "JohnDoe#121",
            "created_at": "2023-02-25T13:19:49.032Z",
            "players": [
                {
                    "played": [],
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "played": [],
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "user": {
                        "username": "RichardRoe"
                    }
                }
            ]
        },
        "hand": [
            "b6",
            "b11",
            "b7"
        ]
    }
}
```
</td> 
<td>  

```json
{
    "status": 400,
    "data": {
        "message": "No es su turno para repartir"
    }
}
```

```json
{
    "status": 400,
    "data": {
        "message": "La partida no ha empezado"
    }
}
```

```json
{
    "status": 400,
    "data": {
        "message": "La partida ya ha terminado"
    }
}
```
</td>
</tr>
<tr>
<td>POST /game/play</td> 
<td> play </td> 
<td> El usuario juega una carta de su mano<br/>Body params: carta, GameNumber </td> 
<td>  

```json
{
    "status": 200,
    "data": {
        "game": {
            "points_us": 0,
            "points_them": 0,
            "players_count": 2,
            "size": 2,
            "state": "started",
            "number": "JohnDoe#121",
            "deals": 1,
            "created_at": "2023-02-25T13:19:49.032Z",
            "players": [
                {
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "played": [
                        "b6"
                    ],
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "played": [],
                    "user": {
                        "username": "RichardRoe"
                    }
                }
            ]
        },
        "hand": [
            "b11",
            "b7"
        ]
    }
}
```

</td> 
<td>  

```json
{
    "status": 400,
    "data": {
        "message": "Debes juar una carta que esté e tu mano"
    }
}
```
```json
{
    "status": 400,
    "data": {
        "message": "La partida no ha empezado"
    }
}
```

```json
{
    "status": 400,
    "data": {
        "message": "La partida ya ha terminado"
    }
}
```
</td>
</tr>
<tr>
<td> POST /game/discard </td> 
<td> discard </td> 
<td> El usuario descarta una carta de su mano<br/>Body params: carta, GameNumber  </td> 
<td>

```json
{
    "status": 200,
    "data": {
        "game": {
            "points_us": 0,
            "points_them": 0,
            "players_count": 2,
            "size": 2,
            "state": "started",
            "number": "JohnDoe#876",
            "deals": 0,
            "created_at": "2023-02-25T13:43:12.672Z",
            "players": [
                {
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "played": [
                        "empty"
                    ],
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "played": [],
                    "user": {
                        "username": "RichardRoe"
                    }
                }
            ]
        },
        "hand": [
            "b7",
            "b11"
        ]
    }
}
```
</td> 
<td>  

```json
{
    "status": 400,
    "data": {
        "message": "No puede descartar una carta que no está en su mano"
    }
}
```

```json
{
    "status": 400,
    "data": {
        "message": "La partida no ha empezado"
    }
}
```

```json
{
    "status": 400,
    "data": {
        "message": "La partida ya ha terminado"
    }
}
```
</td>
</tr>
<tr>
<td> POST /game/add_point </td> 
<td> add_points </td> 
<td> Agrega un punto al equipo pasado como parámetro <br/>Body params: Equipo, GameNumber </td> 
<td> 

```json
{
    "status": 200,
    "data": {
        "game": {
            "state": "started",
            "points_us": 1,
            "points_them": 0,
            "players_count": 2,
            "size": 2,
            "number": "JohnDoe#876",
            "deals": 0,
            "created_at": "2023-02-25T13:43:12.672Z",
            "players": [
                {
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "played": [
                        "empty"
                    ],
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "played": [],
                    "user": {
                        "username": "RichardRoe"
                    }
                }
            ]
        },
        "hand": [
            "b7",
            "b11"
        ]
    }
}
```
 </td> 
<td>
 
```json
{
    "status": "forbbiden",
    "data": {
        "message": "Debes ser admin para añadir puntos"
    }
}
```

```json
{
    "status": 400,
    "data": {
        "message": "La partida debe estar en curso para poder añadir puntos"
    }
}
```

</td>
</tr>
<tr>
<td> POST /game/remove_point </td> 
<td> remove_points </td> 
<td>  Resta un punto al equipo pasado como parámetro<br/>Body params: Equipo, GameNumber</td> 
<td>  

```json
{
    "status": 200,
    "data": {
        "game": {
            "state": "started",
            "points_us": 0,
            "points_them": 0,
            "players_count": 2,
            "size": 2,
            "number": "JohnDoe#876",
            "deals": 0,
            "created_at": "2023-02-25T13:43:12.672Z",
            "players": [
                {
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "played": [
                        "empty"
                    ],
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "played": [],
                    "user": {
                        "username": "RichardRoe"
                    }
                }
            ]
        },
        "hand": [
            "b7",
            "b11"
        ]
    }
}
```
</td> 
<td> 

```json
{
    "status": 400,
    "data": {
        "message": "No se pueden quitar más puntos"
    }
}
```
```json
{
    "status": "forbbiden",
    "data": {
        "message": "Debes ser admin para añadir puntos"
    }
}
```
```json
{
    "status": 400,
    "data": {
        "message": "La partida debe estar en curso para poder añadir puntos"
    }
}
```
</td>
</tr>
<tr>
<td>  GET /game/status </td> 
<td> status </td> 
<td> Muestra los datos de la partida<br/>Body params: GameNumber </td> 
<td> 

```json
{
    "status": 200,
    "data": {
        "game": {
            "points_us": 0,
            "points_them": 0,
            "players_count": 2,
            "size": 2,
            "state": "started",
            "number": "JohnDoe#876",
            "deals": 0,
            "created_at": "2023-02-25T13:43:12.672Z",
            "players": [
                {
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "played": [
                        "empty"
                    ],
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "played": [],
                    "user": {
                        "username": "RichardRoe"
                    }
                }
            ]
        },
        "hand": [
            "b7",
            "b11"
        ]
    }
}
```
</td> 
<td> 

```json
{
    "status": 400,
    "data": {
        "message": "No se ha encontrado el juego"
    }
}
```
</td>
</tr>
<tr>
<td>  POST /game/end</td> 
<td> end_game </td> 
<td>  

```json
{
    "status": 200,
    "data": {
        "game": {
            "state": "finished",
            "points_us": 0,
            "points_them": 0,
            "players_count": 2,
            "size": 2,
            "number": "JohnDoe#876",
            "deals": 0,
            "created_at": "2023-02-25T13:43:12.672Z",
            "players": [
                {
                    "role": "admin",
                    "team": "us",
                    "seat": 0,
                    "played": [
                        "empty"
                    ],
                    "user": {
                        "username": "JohnDoe"
                    }
                },
                {
                    "role": "guest",
                    "team": "them",
                    "seat": 1,
                    "played": [],
                    "user": {
                        "username": "RichardRoe"
                    }
                }
            ]
        },
        "hand": [
            "b7",
            "b11"
        ]
    }
}
```
</td> 
<td>  

```json
{
    "status": "forbbiden",
    "data": {
        "message": "Debes ser admin para terminar la partida"
    }
}
```
```json
{
    "status": 400,
    "data": {
        "message": "La partida debe estar en curso para poder terminar"
    }
}
```
</td>
</tr>
</table>

### Direct Upload

<table>
<tr>
<td> Ruta </td> <td> Endpoint </td> <td> Descripcion </td> <td> Success </td> <td> Error </td>
</tr>  
<tr>
<td> POST  rails/active_storage/direct_uploads </td> 
<td>  create </td>  
<td> Crea un  Blob con el archivo que se le envía </td> 
<td> 

```json
{
    "id": 4,
    "key": "o7hsrzgb5lm8im41fkg1lxciczhd",
    "filename": "bg2.jpg",
    "content_type": "image/jpeg",
    "metadata": {},
    "service_name": "local",
    "byte_size": 314903,
    "checksum": "b9WCe0gQisAiVGUpS5vVuQ==",
    "created_at": "2023-02-25T17:10:52.218Z",
    "signed_id": "eyJfcmFpbHMiOnsibW",
    "attachable_sgid": "BAh7CEkiCGdpZAY6BkVUSSI3",
    "service_url": "http://localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibW/bg2.jpg",
    "direct_upload": {
        "url": "http://localhost:3000/rails/active_storage/disk/<longurl>",
        "headers": {
            "Content-Type": "image/jpeg"
        }
    }
}
```

</td>
<td> - </td>
</tr>

</table>
