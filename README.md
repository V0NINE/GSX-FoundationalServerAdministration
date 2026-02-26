# GSX-FoundationalServerAdministration

## Initial Configuration

Partint de la snapshot *clean-install* de la imatge debian-gsx, hi ha alguna configuració que s'ha de fer manualment.

#### Activar Port Forwarding

La configuració de l'adaptador de xarxa de la VM que utilitzem és amb mode NAT, que ens permet actuar com si la màquina estés connectada a una xarxa privada interna, amb l'*Oracle VM VirtualBox networking engine* actuant com un router entre el *guest* (VM) i la xarxa del *host* (Computador).

Per que un servei en concret del *guest* (un servior SSH en el nostre cas) sigui accessible des del *host*, haurem d'afegir una regla de *port forwaring* al "router" d'*Oracle VM VirtualBox*.

Els passos per fer-ho són, amb el *guest* aturat:
1. Obrir el menú de Configuració
2. Anar a la secció de Xarxa
3. A la pestanya d'Adaptador 1, comprovar que està amb mode NAT
4. Aquí mateix, desplegar l'opció Avançat
5. Obrir el menú de Regles de reenviament de ports
6. Clicar el botó d'afegir una nova regla de reenviament de ports
7. Configurar les opcions amb: 
    Nom -> ssh-forwarding (opcional) / Protocol -> TCP
    IP amfitrió (host) -> res / Port amfitrió -> 2222
    IP invitat (guest) -> res / Port invitat -> 22
8. Clicar el botó Acceptar

Ara des del *host* ja podrem accedir al servei SSH mitjançant `ssh -p 222 usuari@localhost`.

#### Configuracions des del Servidor

Abans de poder connectar-nos com a sysadmin des de la nostra màquina, s'han d'executar alguns scripts des del pròpi servidor per poder incloure l'usuari del sysadmin al sudoers file i establir el servei ssh.

Cal tenir en compte que els següents scripts s'han d'executar com a **root**. Caldrà executar `su -` i introduïr la contrassenya de root

##### Executar 'configure_sudoers.sh'
Aquest script afegeix una llista d'usuaris sysadmin (almenys un) al sudoers file perque puguin executar comandes de superusuari.

Realitza totes les comprovacions pertinets, des de comprovar que l'usuari existeix, que no estigui ja al *sudoers file*, etc. 

**EXIT CODES**: 0: Ha pogut afegir tots els usuaris de la llista
           -1: No ha rebut cap paràmetre d'entrada. Se n'ha de passar almenys un
            1: Si *visudo* ha detectat errors en algun dels fitxers

La comanda per executar-lo és `./configure_sudoers.sh` \<usuari\> \<usuari\> ...

##### Executar 'start_ssh.sh'
Aquest script instal·la el paquet *openssh-server* i arranca el servei ssh. No rep paràmetres d'entrada.

Si el paquet ja estava instal·lat o el servei ja estava en funcionament dona un avís però no falla l'execució.

Pel que fa al servei, si l'script no el pot ficar a **enable** dona un avís, però continua l'execució. Mentre que si no el pot arrancar, l'script falla.

**EXIT CODES**: 0: Tot correcte. Tant si ha hagut de realitzar alguna acció com si ja estava tot fet
            1: Algun error amb *apt-get*
            2: No s'ha pogut arrancar el servei

La comanda per executar-lo és `./start_ssh.sh`

## Documentation

- [SSH Basics - Video](https://www.youtube.com/watch?v=WwGRGfLy6q8&list=WL&index=4)
- [Virtual Networking - Documentation](https://www.virtualbox.org/manual/ch06.html)
- [Public Key Authentication](https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Public_Key_Authentication#Basics_of_Public_Key_Authentication)
