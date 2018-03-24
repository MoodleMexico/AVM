# Aulas Virtuales Móviles
Puntos de acceso WiFi a contenidos educativos, usando arjetas de desarrollo Raspberry Pi 3 y Pi Zero W.


***


## Requerimientos


***


* Computadora con acceso a Internet
* Un switch de 4 puertos
* Tarjeta de desarrollo Raspberry Pi 3
* Tarjeta de Memoria Micro SD de 32Gb
* Adaptador para leer la tarjeta Micro SD




***


La forma más fácil de crear la tarjeta MicroSD para las tarjetas es:
```bash
curl -sSL https://moodlemexico.github.io/AVM/crea_microsd.sh | bash -s /dev/sdX TU_DOMINIO
```

Dónde X es tu tarjeta MicroSD y 
TU_DOMINIO es el dominio al cual quieres que accedan los usuario.


Ejemplo: comunidadmoodlemexico.org  <==== Ojo sin "http://"



## 1.- Preparación de la tarjeta Micro SD


***


### 1.1. Descarga del archivo del Sistema Operativo
Lo primero es descargar la imagen de Raspbian versión Lite desde el [sitio oficial](https://www.raspberrypi.org/downloads/raspbian/ "Descarga Raspbian desde el Sitio Oficial"), puedes descargar la versión _**[torrent](https://downloads.raspberrypi.org/raspbian_lite_latest.torrent "Descarga Raspbian Lite en por medio de torrent")**_ o en formato _**[zip](https://downloads.raspberrypi.org/raspbian_lite_latest "Descarga Raspbian Lite en formato zip")**_. 



### 1.2. Verificación del archivo
Es importante verificar que se ha descargado el archivo correctamente, comparando la cadena del archivo en la página, con la cadena que se genera en con el siguiente comando:
```bash
sha256sum 2017-11-29-raspbian-stretch-lite.zip
```

y debe dar por resultado una cadena igual a.
```console
e942b70072f2e83c446b9de6f202eb8f9692c06e7d92c343361340cc016e0c9f  2017-11-29-raspbian-stretch-lite.zip
```

### 1.3. Descomprime el archivo de  la imagen del sistema operativo 
```bash
unzip 2017-11-29-raspbian-stretch-lite.zip 
```

y se obtiene de resultado
```console
Archive:  2017-11-29-raspbian-stretch-lite.zip
  inflating: 2017-11-29-raspbian-stretch-lite.img  
```

### 1.4. Copia de imagen a tarjeta de memoria Micro SD
1.4.1. Cambia de usuario a **`root`**
```bash
sudo su
```

1.4.2. Realiza una copia binaria utilizando el comando **dd**
```bash
dd if=2017-11-29-raspbian-stretch-lite.img  of=/dev/sdX bs=512k conv=fsync 
```

La unidad **`sdX`** depende de tu equipo en cual reconoce la tarjeta de memoria Micro SD.


Al finalizar mostrará el siguiente mensaje
```console
3544+0 registros leídos
3544+0 registros escritos
1858076672 bytes (1.9 GB, 1.7 GiB) copied, 91.9325 s, 20.2 MB/s
```



***


## 2.- Preparación de la tarjeta Raspberry Pi 3


***


- [x] Conecta la tarjeta Micro SD a la Raspberry Pi 3.
- [x] Conecta la Raspberry Pi a una pantalla utilizando un cable HDMI.
- [x] Conectale un teclado a uno de los puertos USB  de la Raspberry Pi.
- [x] Conecta un cable de alimentación al puerto micro USB.
- [x] Conecta un cable de red de la Raspberry Pi al puerto del switch o ruteador.



***


### 2.1. Inicio por primera vez
La primera vez que arranca la tarjeta de desarrollo Raspberry Pi 3 con la tarjeta de memoria con la imagen cargada, se configurará en forma automática para utilizar todo el espacio disponible en la tarjeta de memoria.

2.1.1. Una vez que se ha reiniciado el sistema, ingresamos con el usuario `pi` y la contraseña `raspbian`
```bash
Raspbian GNU/Linux 9 raspberrypi tty1
raspberry login: pi
Password: raspberry
```

Y nos muestra el siguiente mensaje.
```console
Linux raspberrypi 4.9.59-v7+ #1047 SMP Sun Oct 29 12;19;23 GMT armv71

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms of each program are described in the 
individual files in /usr/share/doc/*copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRYTY, to the extent
permited by applicable law.
pi@raspberrypi:~ $_
```

2.1.2. Cambiamos de usuario a `root` para  configurar la tarjeta de desarrollo Raspberry Pi 3.
```bash
sudo su
```


***


### 2.2. Actualización de los paquetes
Ya que la imagen que se descarga e instala en la tarjeta micro sd puede ser que contenga algunos paquetes que han sido actualizados corrigiendo algún fallo de seguridad, o simplemente mejorando alguna caracteríztica, para buscar y actulizar a la última versión introducimos los siguientes comandos.
```bash
apt update
apt -y dist-upgrade
```

### 2.3. Actualizamos el firmware 
```bash
rpi-update
```

### 2.4. Configuración de la raspberry pi
Mediante la herramienta `raspi-config`, cambiamos la contraseña por default y configuramos otros detalles como el nombre del host, la localización, así como activar el servicio SSH entre otros.
```bash
raspi-config
```

Una vez que se ha terminado el proceso de configuracin, reiniciamos la tarjeta de desarrollo raspberry pi.
```bash
reboot
```


***


## 3.- Instalación de paquetes


***


### 3.1. Ingresamos a la consola 
Una vez que se ha reiniciado el sistema, ingresamos con el usuario `pi` y la contraseña que hayamos configurado en el paso anterior, para que una vez que hayamos ingresado al sistema cambiarnos de usuario a `root`.
```bash
sudo su
```

### 3.2. Instalación de Herramientas
3.2.1. Editor de textos Vim
```bash
apt -y install vim
```

3.2.2. Corrector ortográfico
```bash
apt -y install aspell
```

3.2.3. Software de control de versiones
```bash
apt -y install git
```

3.2.4. Instalacin de servidor de base de datos MariaDB
```bash
apt -y install mariadb-server mariadb-client
```

3.2.5. Instalación de servidor de base de datos PostgreSQL
```bash
apt -y install postgresql-9.6 postgresql-client
```

3.2.6. Instalación de servidor web Apache
```bash
apt -y install -t stretch apache2
```

3.2.7. Activa Mod Rewrite 
```bash
a2enmod rewrite
```

3.2.8. Instala Mod PHP 7.0
```bash
apt -y install -t stretch libapache2-mod-php7.0
```

3.2.9. Instala extensiones de PHP para bases de datos
```bash
apt -y install -t stretch php7.0-mysql php7.0-pgsql 
```

3.2.10. Instala complementos de PHP
```bash
apt -y install -t stretch php7.0-zip php7.0-curl php7.0-gd php7.0-intl php7.0-xml php7.0-xmlrpc php7.0-soap php7.0-mbstring php7.0-fpm php7.0-ldap php7.0-mcrypt php7.0-geoip
```

3.2.11. Instalación de DNSmasq
```bash
apt -y install dnsmasq
```

3.2.12. Instala HostAPD
```bash
apt -y install hostapd
```

3.2.13. Descarga de CMS [Joomla!](https://www.joomla.org)
```bash
cd /var/www/html
git clone https://github.com/joomla/joomla-cms.git
```

3.2.14. Descarga de LMS Moodle
```bash
cd /var/www/html
git clone https://github.com/moodle/moodle.git
```

3.2.15. Descarga Motambo 
```bash
cd /var/www/html
git clone https://github.com/piwik/piwik.git .
cd piwik
git submodule update --init --recursive
curl -sS https://getcomposer.org/installer | php 
php composer.phar install --no-dev
php console development:disable
```

3.2.16. Descarga la [Wikipedia en Español](https://download.kiwix.org/zim/wikipedia/)
```bash
mkdir /var/www/html/wikipedia
cd /var/www/html/wikipedia
wget http://download.kiwix.org/zim/wikipedia/wikipedia_es_all_2017-05.zim
```

3.2.17. Descarga Kiwix 
```bash
cd /home/pi
wget http://download.kiwix.org/bin/kiwix-server-arm.tar.bz2
tar -xjvf kiwix-server-arm.tar.bz2
cp kiwix-serve /usr/bin/

cat > /etc/rc.local << EOF
#!/bin/sh -e

# Imprimir dirección(es) IP
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "Mi dirección IP es %s\n" "$_IP"
fi

# Iniciar servicio Wikipedia
/usr/bin/kiwix-serve --port=8080 --daemon /var/www/html/wikipedia/wikipedia_es_all_2017-05.zim

exit 0
EOF
```


***


## 4.- Bases de Datos


***


### 4.1. Creación de base de datos para el sistema administrador de contenidos Joomla!
```bash
su postgres -c "psql -c \"create user usrjoomladb;\""
su postgres -c "psql -c \"alter user usrjoomladb encrypted password 'password';\""
su postgres -c "psql -c \"create database joomladb;\""
su postgres -c "psql -c \"alter database joomladb owner to usrjoomladb;\""
```

### 4.2. Creación de base de datos para el LMS Moodle
```bash
su postgres -c "psql -c \"create user usrmoodledb;\""
su postgres -c "psql -c \"alter user usrmoodledb encrypted password 'password';\""
su postgres -c "psql -c \"create database moodledb;\""
su postgres -c "psql -c \"alter database moodledb owner to usrmoodledb;\""
```

### 4.3. Creación de base de datos para Motambo (antes PIWIK)
```bash
mysql -u root -ppassword -e "CREATE DATABASE motambodb"
mysql -u root -ppassword -e "GRANT ALL ON motambodb.* TO 'motambodb'@'localhost' identified by 'password';"
```


***


## 5.- Permisos de archivos y directorios



***


### 5.1. Propietarios de archivos
```bash
chown -R www-data:www-data /var/www
```

### 5.2. Permisos de archivos en directorio de archivos web
```bash
find /var/www -type d -exec chmod 755 {} \;
find /var/www -type f -exec chmod 644 {} \;
```


***


## 6.- Configuraciones y servicios


***


### 6.1. Reiniciando Apache
```bash
systemctl restart apache2
```

### 6.2. Tarjetas de Red
```bash
cat > /etc/network/interfaces << EOF
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet dhcp

auto wlan0
allow-hotplug wlan0

iface wlan0 inet static
  address 192.168.100.1
  netmask 255.255.255.0

up iptables-restore < /etc/iptables.ipv4.nat
EOF
```

### 6.3. Firewall
```bash
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

iptables-save > /etc/iptables.ipv4.nat
```

### 6.4. WiFi Abierta
Se edita el archivo de configuración del servicio hostap
```bash
cat > /etc/hostapd/hostapd.conf << EOF 
interface=wlan0
ssid=Aula_Virtual
hw_mode=g
channel=6
auth_algs=1
wmm_enabled=0
ieee80211n=1          # 802.11n support
wmm_enabled=1         # QoS support
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
EOF
```

### 6.5. HostAPD
Se inicia y configura el servicio hostapd
```bash
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd
service hostapd start
update-rc.d hostapd enable
```

### 6.6. Servidor de Nombres de Dominios - DNS
https://www.dd-wrt.com/wiki/index.php/DNSMasq_as_DHCP_server

```bash
cat > /etc/dnsmasq.conf << EOF 
domain-needed
bogus-priv
local=/aula_virtual/ 
expand-hosts

interface=wlan0
listen-address=127.0.0.1,192.168.100.1

domain=nodo_comunitario
no-resolv
cache-size=4096

dhcp-range=wlan0,192.168.100.100,192.168.100.150,255.255.255.0,12h
dhcp-option=option:router,192.168.100.1
dhcp-option=252,"\n"

address=/aula_virtual/192.168.100.1
EOF
```


***


## 7.- Información del Nodo para el Desarrollo Comunitario


***


7.1. Instala los paquetes necesarios para activar el bluetooth
```bash
apt-get -y install libbluetooth-dev libopenobex1 openobex-apps obexftp obexpushd pi-bluetooth
apt-get -y install libxml2-dev 
apt-get -y install python-pip python-dev ipython
apt-get -y install bluetooth bluez-tools libbluetooth-dev
pip install pybluez
```

7.2. Beacon - Para poner el Bluetooth de la Raspberry como identificador Beacon para apps 
```bash
hciconfig hci0 up
hciconfig leadv 3
hciconfig noscan
hcitool -i hci0 cmd 0x08 0x0008 1b 02 01 06 03 03 aa fe 13 16 aa fe 10 00 02 69 6e 74 65 67 72 61 63 69 07 2e 6d 78 00 00 00 00
```




***


## 8.- Carga de contenidos


***

* Instalación y configuracin de [Joomla!](https://docs.joomla.org/J3.x:Installing_Joomla)
* Directorio de negocios [SobiPro](https://www.sigsiu.net/)
* Instalación de LMS [Moodle](https://docs.moodle.org/34/en/Installing_Moodle)
* Cursos disponibles para descarga en [Moodle.NET](https://moodle.net "La red de recursos disponibles de la comunidad Moodle")


*** 


# Por Hacer
* Instalación de [A-Frame](https://aframe.io/ "Realidad Virtual con Mozilla A-Frame") para Readlidad Virtual.
* http://blockbuilder.org/search#text=aframe


***


# Referencias:
* http://www.argenox.com/bluetooth-low-energy-ble-v4-0-development/library/a-ble-advertising-primer/
* http://www.wadewegner.com/2014/05/create-an-ibeacon-transmitter-with-the-raspberry-pi/
* http://www.makeuseof.com/tag/build-diy-ibeacon-raspberry-pi/
* https://learn.adafruit.com/pibeacon-ibeacon-with-a-raspberry-pi
* https://www.uuidgenerator.net/
* https://www.famkruithof.net/uuid/uuidgen
* http://yencarnacion.github.io/eddystone-url-calculator/
