Partim d’una instal·lació neta (*clean install*), sense `sudo`, `ssh`, etc.  
  
---  
  
## 1. Port Forwarding  
  
Abans d’arrencar la VM per primer cop, cal crear una regla de *port forwarding* que utilitzarem per connectar-nos via SSH.  
  
**Passos:**  
- Configuració > Xarxa > Avançat > Reenviament de ports > Afegir  
  
**Paràmetres a modificar:**  
- **Port amfitrió:** `2222`  
- **Port convidat:** `22`  
  
Això permet utilitzar el port `2222` del host per connectar-nos al servidor SSH de la màquina virtual.  
  
---  
  
## 2. Carpeta compartida  
  
Per poder executar els scripts de l’administrador de sistemes, crearem una carpeta compartida entre el host i la màquina virtual.  
  
**Passos:**  
- Configuració > Carpetes compartides > Afegir  
  
S’ha d’especificar la ruta de la carpeta que es vol compartir i marcar la casella **Automuntar**.

---

## 3. Execució de scripts

Ara ja podem arrencar la màquina virtual.

**Passos previs:**

1. Obrir una shell  
2. Entrar com a root:

```bash
su -
```

3. Moure’s a la carpeta compartida, on es troben els scripts

Un cop allí, s’han de seguir els passos següents:

___
### 3.1 configure_sudoers.sh

Executar l’script:

```
./configure_sudoers.sh <usuaris>
```

Rep com a paràmetre el llistat d’usuaris que vols afegir al grup sudo. En principi, s’ha d’afegir únicament `gsx`.

L’script afegirà els usuaris a `/etc/sudoers.d/` i, si tot va bé, tindran permisos de superusuari.

---
### 3.2 setup_ssh_server.sh

Executar l’script sense cap paràmetre:

```
./setup_ssh_server.sh
```

Aquest script instal·la i arrenca el servei `openssh-server`, amb les comprovacions pertinents per tal de ser idempotent.

---
### 3.3 Configuració SSH

Executar l’script amb mode bootstrap:

```
./configure_ssh_access.sh --mode bootstrap
```

Aquest mode permet establir connexió SSH amb contrasenya, entre altres opcions.

Des del host, a la carpeta `~/.ssh/`, crear la parella de claus:

```
ssh-keygen -t ed25519 -f <nom_clau> -N ""
```

Enviar la clau pública al servidor:

```
ssh-copy-id -i <nom_clau> -p 2222 gsx@localhost
```

Comprovar la connexió:

```
ssh -i <nom_clau> -p 2222 gsx@localhost
```

Si ha funcionat correctament, des de la màquina virtual executar:

```
./configure_ssh_access.sh --mode secure
```
