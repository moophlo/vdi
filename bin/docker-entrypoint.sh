#!/bin/bash


PASSWORD=${PASSWORD:="XeF5jW7qbneXjawd"}
PASSWORDHASH=$(openssl passwd -1 $PASSWORD)

# Add sample user
# sample user uses uid 999 to reduce conflicts with user ids when mounting an existing home dir
# the below has represents the password 'ubuntu'
# run `openssl passwd -1 'newpassword'` to create a custom hash
if [ ! $PASSWORDHASH ]; then
    export PASSWORDHASH='$1$1osxf5dX$z2IN8cgmQocDYwTCkyh6r/'
fi

USERNAME=${USERNAME:="vdi"}
USRSHELL=${USRSHELL:="/bin/bash"}
addgroup --gid 999 $USERNAME && \
useradd -m -u 999 -s $USRSHELL -g $USERNAME $USERNAME
echo "$USERNAME:$PASSWORDHASH" | /usr/sbin/chpasswd -e
echo "$USERNAME    ALL=(ALL) ALL" >> /etc/sudoers
unset PASSWORDHASH
unset USERNAME
unset PASSWORD
unset USRSHELL

# Container variables and files configuration

set_property_in_file() {
	FILE="$1"
	PATTERN="$2"
	VALUE="$3"
	RETVAL=199
	echo "setting $PATTERN as $VALUE in $FILE"
	sed "s/\#$PATTERN\#/$VALUE/g" $FILE -i
	RETVAL=$?
	if [ $RETVAL -ne 0 ]
	then
    		echo "Variabile $PATTERN non inserita in $FILE, fermo il container."
    		exit 199
	fi
}

#standalone-full.xml
set_property_in_file /etc/krb5.conf "AD_REALM" $AD_REALM
set_property_in_file /etc/samba/smb.conf "AD_REALM" $AD_REALM
set_property_in_file /etc/samba/smb.conf "AD_DOMAIN" $AD_DOMAIN

# Container startup commands
if [ "$( echo $CMD1 $CMD2 $CMD3 $CMD4 $CMD5 $CMD6 $CMD7 $CMD8 $CMD9 $CMD10 | grep apt)" ]
then
    apt update
    $CMD1
    $CMD2
    $CMD3
    $CMD4
    $CMD5
    $CMD6
    $CMD7
    $CMD8
    $CMD9
    $CMD10
else
    $CMD1
    $CMD2
    $CMD3
    $CMD4
    $CMD5
    $CMD6
    $CMD7
    $CMD8
    $CMD9
    $CMD10
fi
    
    
    




# Add the ssh config if needed

if [ ! -f "/etc/ssh/sshd_config" ];
	then
		cp /ssh_orig/sshd_config /etc/ssh
fi

if [ ! -f "/etc/ssh/ssh_config" ];
	then
		cp /ssh_orig/ssh_config /etc/ssh
fi

if [ ! -f "/etc/ssh/moduli" ];
	then
		cp /ssh_orig/moduli /etc/ssh
fi

# generate fresh rsa key if needed
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ];
	then 
		ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi

# generate fresh dsa key if needed
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ];
	then 
		ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

#prepare run dir
mkdir -p /var/run/sshd

# generate xrdp key
if [ ! -f "/etc/xrdp/rsakeys.ini" ];
	then
		xrdp-keygen xrdp auto
fi

# generate machine-id
uuidgen > /etc/machine-id

# join domain
echo "Join Domain"
#apt update
#apt install winbind dnsutils net-tools samba samba-common winbind libpam-winbind libnss-winbind krb5-config samba-dsdb-modules samba-vfs-modules cifs-utils -yy
pam-auth-update --force
#net ads join -U $AD_USER%$AD_PASSWORD -S $DEFAULT_REALM
#service winbind restart
#service dbus restart


adduser xrdp ssl-cert


# Add .xsession to ldap users
echo "Aggiungo la configurazione di .Xsession per ldap users"

sed -i '/^test -x.*/i echo xfce4-session > ~/.Xsession' /etc/xrdp/startwm.sh
sed -i '/^echo xfce4-session.*/i unset DBUS_SESSION_BUS_ADDRESS' /etc/xrdp/startwm.sh
sed -i '/^unset DBUS_SESSION_BUS_ADDRESS/i unset XDG_RUNTIME_DIR' /etc/xrdp/startwm.sh
sed -i 's/thinclient_drives/shared-drive/g' /etc/xrdp/sesman.ini


sed -i '/PASSWORD=${PASSWORD:="XeF5jW7qbneXjawd"}/d' /usr/bin/docker-entrypoint.sh

# set keyboard for all sh users
echo "export QT_XKB_CONFIG_ROOT=/usr/share/X11/locale" >> /etc/profile




exec "$@"
