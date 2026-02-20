# GSX-FoundationalServerAdministration

## Initial Configuration

Partint de la snapshot *clean-install* de la imatge debian-gsx, hi ha alguna configuració que s'ha de fer manualment.

#### Activar Port Forwarding

La configuració de l'adaptador de xarxa de la VM que utilitzem és amb mode NAT, que ens permet actuar com si la màquina estés connectada a una xarxa privada interna, amb l'*Oracle VM VirtualBox networking engine* actuant com un router entre el *guest* (VM) i la xarxa del *host* (Computador).

Per que un servei en concret del *guest* (un servior SSH en el nostre cas) sigui accessible des del *host*, haurem de configurar una regla de *port forwaring* al "router" d'*Oracle VM VirtualBox*.

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

## Documentation

- [SSH Basics - Video](https://www.youtube.com/watch?v=WwGRGfLy6q8&list=WL&index=4)
- [Virtual Networking - Documentation](https://www.virtualbox.org/manual/ch06.html)
- [Public Key Authentication](https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Public_Key_Authentication#Basics_of_Public_Key_Authentication)
