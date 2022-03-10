# vdi
===============

Questo progetto si basa su quello di Daniel Guerra: danielguerra/ubuntu-xrdp sul Docker Hub, https://github.com/danielguerra69/ubuntu-xrdp

L'entrypoint è stato modificato da:

~~~
#!/bin/bash
PASSWORDHASH=$(openssl passwd -1 $PASSWORD)
#...
if [ ! $PASSWORDHASH ]; then
    export PASSWORDHASH='$1$1osxf5dX$z2IN8cgmQocDYwTCkyh6r/'
fi

addgroup --gid 999 ubuntu && \
useradd -m -u 999 -s /bin/bash -g ubuntu ubuntu
echo "ubuntu:$PASSWORDHASH" | /usr/sbin/chpasswd -e
echo "ubuntu    ALL=(ALL) ALL" >> /etc/sudoers
unset PASSWORDHASH
~~~

a:

~~~
PASSWORDHASH=$(openssl passwd -1 $PASSWORD)
#...
if [ ! $PASSWORDHASH ]; then
    export PASSWORDHASH='$1$1osxf5dX$z2IN8cgmQocDYwTCkyh6r/'
fi

addgroup --gid 999 $USERNAME && \
useradd -m -u 999 -s /bin/bash -g $USERNAME $USERNAME
echo "$USERNAME:$PASSWORDHASH" | /usr/sbin/chpasswd -e
#echo "$USERNAME    ALL=(ALL) ALL" >> /etc/sudoers
unset PASSWORDHASH
unset USERNAME
unset PASSWORD
~~~

In questo modo non sarà necessario inserire un hash come variabile d'ambiente in rancher, il che ci permette di verificare la password in ogni momento ed elimina i problemi dovuti ai caratteri speciali ($ su tutti) propri degli hash generati tramite gli algoritmi crittografici utilizzati da ubuntu.

~~~
Reminder:
$1$... hash generato con algoritmo MD5 (anche $md5$)
$2$... algoritmo blowfish
$5$... SHA256
$6$... SHA512
~~~

Sono previste le variabili d'ambiente CMD1...CMD10 con cui si possono specificare ulteriori comandi, incluse installazioni di pacchetti.
Qualora in una di queste variabili fosse predente la stringa "apt", l'entrypoint eseguirà automaticamente un "apt update" prima di eseguire il resto.

