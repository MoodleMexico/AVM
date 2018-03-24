#!/usr/bin/sh
###############################################################################
# Comunidad Moodle México - Aula Virtual Móvil
# Script para crear las tarjetas MicroSD para una Aula Virtual Móvil, en una
# Raspberry Pi 3.
#
# Actualizado para la versión: 2017-11-29-raspbian-stretch-lite
# 
# Uso: - Descargue el archivo
#      - Inserte su tarjeta MicroSD
#      - Ejecute como usuario root
#        ./crea_microsd.sh /dev/sdX     <===== X es la tarjeta MicroSD
#      - Inserta la tarjeta en la tarjeta Raspberry.
#      - Conecta la Raspberry Pi a la red usando un cable.
#      - Conecta la alimentación.
#      - Opcional conecta el puerto HDMI de la Raspberry a un monitor.
#      - Ve por un café
#      - Ve por el segundo café, este proceso es un poco lento ya que 
#        son descargados muchos archivos de Internet que tienen un tamaño 
#        considerable como la Wikipedia en Español - 16G aproximadamente.
#
# Autores: Jorge Diaz - jorge.diaz@gmail.com / jorge@integraci.com.mx
#          Odin Mojica - odinmojica@gmail.com / odin@integraci.com.mx
#
# Licencia: GNU General Public License Versión 3 - http://www.gnu.org/licenses
###############################################################################
# 1.- Variables
###############################################################################
NOMBRE_PROYECTO="aulas_virtuales_moviles"
DOMINIO_RASPBERRY="192.168.100.1"
DIRECTORIO_TRABAJO="/tmp/$NOMBRE_PROYECTO"
UNIDAD_MICROSD=$1                     # Valor introducido al ejecutar el script
ARCHIVO_RASPBIAN="2017-11-29-raspbian-stretch-lite"      # Nombre SIN extensión
URL_RASPBIAN="https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-12-01/"
# Moodle
BD_MOODLE="moodledb"
USUARIO_BD_MOODLE="usrmoodledb"
CONTRASENA_USUARIO_BD_MOODLE="123456789"
RUTA_MOODLEDATA="/var/www/moodledata"
LENGUAJE_SITIO_MOODLE="es_mx"
USUARIO_ADMINISTRADOR_MOODLE="admin"
CONTRASENA_USUARIO_ADMINISTRADOR_MOODLE="password"
CORREO_ELECTRONICO_ADMINISTRADOR_MOODLE="contacto@integraci.com.mx"
NOMBRE_COMPLETO_SITIO_MOODLE="Aula Virtual Móvil"
NOMBRE_CORTO_SITIO_MOODLE="AVM"
###############################################################################
# 2.- Creación de directorio de trabajo
###############################################################################
if [ ! -d $DIRECTORIO_TRABAJO ]; then
   mkdir $DIRECTORIO_TRABAJO
fi
cd $DIRECTORIO_TRABAJO
###############################################################################
# 3.- Verificar que el usuario sea root
###############################################################################
verifica_root(){
   if [[ $EUID -ne 0 ]]; then
      echo -e "\n\e[1;31mPara crear la MicroSD es necesario ejecutar como \e[1;37mroot\e[1;31m.\e[0m\n"
      exit 1
   fi
}
###############################################################################
# 4.- Verificar si ingresó la unidad dónde se encuentra la MicroSD
###############################################################################
verifica_usb(){
   if [ -z $UNIDAD_MICROSD ]; then
      echo -ne "\n\e[1;31mNo indicó que unidad\e[0m\n"
      exit 1
   else 
      if [ ! -e $UNIDAD_MICROSD ]; then
         echo -ne "\n\e[1;31mNo existe el punto de montaje: \n\e[1;37m$UNIDAD_MICROSD\e[0m\n"
         exit 1
      fi
   fi
}
###############################################################################
# 5.- Descarga Raspbian
###############################################################################
descarga_raspbian(){
   # Descarga archivo con imagen comprimida
   if [ ! -f $ARCHIVO_RASPBIAN.zip ]; then
      echo -ne "\e[1;32mSe descargará el archivo: \e[1;37m$ARCHIVO_RASPBIAN.zip\e[0m\n"
      wget $URL_RASPBIAN$ARCHIVO_RASPBIAN.zip
   fi
   # Descarga archivo de verificación
   if [ ! -f $ARCHIVO_RASPBIAN.zip.sha256 ]; then
      echo -ne "\e[1;32mSe descargará el archivo: \e[1;37m$ARCHIVO_RASPBIAN.zip.sha256\e[0m\n"
      wget $URL_RASPBIAN$ARCHIVO_RASPBIAN.zip.sha256
   fi
   # Verifica el archivo con la imagen comprimida
   if ! command sha256sum -c $ARCHIVO_RASPBIAN.zip.sha256; then
      echo -ne "\n\e[1;31mLa verificación no ha sido exitosa, se descargará de nuevo.\e[0m\n"
      rm -f $ARCHIVO_RASPBIAN.*
      sleep 5
      verifica_raspbian_lite
   else 
      echo -ne "\n\e[1;32mEl archivo comprimido es correcto...\e[0m\n"
      # Borra el archivo de imagen anterior
      if [ -f $ARCHIVO_RASPBIAN.img ]; then
         rm $ARCHIVO_RASPBIAN.img
      fi
      # Descomprime el archivo para extraer el archivo .img
      unzip $ARCHIVO_RASPBIAN.zip
   fi
}
###############################################################################
# 6.- Crea archivos
###############################################################################
# Plantilla para archivo /etc/rc.local para Raspberry
cat > $DIRECTORIO_TRABAJO/rc.local << FIN_ARCHIVO
#!/bin/sh -e
# Imprimir dirección(es) IP
_IP=\$(hostname -I) || true
if [ "\$_IP" ]; then
  printf "Mi dirección IP es %s\n" "\$_IP"
fi
CAMBIAR_TEXTO
exit 0
FIN_ARCHIVO
###############################################################################
# Script para actualización de paquetes en Raspberry
cat > $DIRECTORIO_TRABAJO/actualiza_paquetes.sh << FIN_ARCHIVO
#!/bin/sh -e
apt update
apt -y dist-upgrade
yes | rpi-update
# Actualiza el zona de tiempo
cp /usr/share/zoneinfo/Mexico/General /etc/localtime
# Localización UTF8 español mexicano
echo "es_MX.UTF-8 UTF-8" >> /etc/locale.gen
update-locale es_MX.UTF-8
# Cambio de idioma de teclado a español latinoamericano
sed -i "s|gb|latam|" /etc/default/keyboard
cat /usr/lib/NOMBRE_PROYECTO/rc.local > /etc/rc.local
sed -i "s|CAMBIAR_TEXTO|/bin/sh /usr/lib/NOMBRE_PROYECTO/instala_paquetes.sh|" /etc/rc.local
reboot
exit 0
FIN_ARCHIVO
###############################################################################
# Inicia Beacon de identificación
cat > $DIRECTORIO_TRABAJO/inicia_beacon.sh << FIN_ARCHIVO
#!/bin/sh
/bin/hciconfig hci0 up
/bin/hciconfig hci0 leadv 3
/bin/hciconfig hci0 noscan
/usr/bin/hcitool -i hci0 cmd 0x08 0x0008 1b 02 01 06 03 03 aa fe 13 16 aa fe 10 00 02 69 6e 74 65 67 72 61 63 69 07 2e 6d 78 00 00 00 00
exit 0
FIN_ARCHIVO
###############################################################################
# Script para instalación de paquetes en Raspberry 
# Se remueve la opción "-ne" en los "echo" ya que se ejecutarán por rc.local
cat > $DIRECTORIO_TRABAJO/instala_paquetes.sh << FIN_ARCHIVO
#!/bin/sh -e
# Editor Vim
apt -y install vim
# Corrector ortográfico
apt -y install aspell
# Control de versiones
apt -y install git
# Servidor de Base de Datos PostgreSQL
apt -y install postgresql-9.6 postgresql-client
# Instalación de servidor HTTP Apache
apt -y install -t stretch apache2
# Mod PHP 7.0
apt -y install -t stretch libapache2-mod-php7.0
# Extensiones de PHP para bases de datos
apt -y install -t stretch php7.0-mysql php7.0-pgsql 
# Complementos adicionales de PHP
apt -y install -t stretch php7.0-zip php7.0-curl php7.0-fpm php7.0-gd php7.0-intl php7.0-xml php7.0-xmlrpc php7.0-soap php7.0-mbstring php7.0-ldap php7.0-mcrypt php7.0-geoip
# DNSmasq
apt -y install dnsmasq
# HostAPD
apt -y install hostapd
# Beacon Bluetooth
apt-get -y install libbluetooth-dev libopenobex2 openobex-apps obexftp obexpushd pi-bluetooth
apt-get -y install libxml2-dev 
apt-get -y install python-pip python-dev ipython
apt-get -y install bluetooth bluez-tools libbluetooth-dev
pip install pybluez
cd /var/www/html
# Descarga de LMS Moodle
echo "\n\e[1;32mDescargando archivos de: \e[1;37mLMS Moodle\e[0m"
git clone https://github.com/moodle/moodle.git
mv moodle/* /var/www/html/
cp config-dist.php config.php
mkdir /var/www/moodledata
wget https://download.moodle.org/download.php/direct/langpack/3.5/es_mx.zip
unzip es_mx.zip -d /var/www/moodledata/lang
# Wikipedia en Español
echo "\n\e[1;32mDescargando: \e[1;37mWikipedia en Español\e[0m"
mkdir /var/www/wikipedia
cd /var/www/wikipedia
#wget -O wikipedia.zim http://download.kiwix.org/zim/wikipedia/wikipedia_es_all_2017-05.zim
# Descarga Kiwix
wget -O kiwix.tar.bz2 http://download.kiwix.org/bin/kiwix-server-arm.tar.bz2
tar -xjvf kiwix.tar.bz2 kiwix-serve
mv kiwix-serve /usr/bin/
rm -f kiwix.tar.bz2
# Inicia kiwix al arrancar
cat > /etc/init.d/kiwix << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          kiwix
# Required-Start:    \$all
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6 
# Short-Description: Inicia Kiwix
# Description:       Arranca la Wikipedia al iniciar
### END INIT INFO
/usr/bin/kiwix-serve --port=8080 --daemon /var/www/wikipedia/wikipedia.zim
exit 0
EOF
chmod +x /etc/init.d/kiwix
update-rc.d kiwix defaults
update-rc.d kiwix enable
# Permisos de archivos y directorios
echo "\n\e[1;32mCambiando propietario a archivos en \e[1;37m/var/www\e[0m"
chown -R www-data:www-data /var/www
echo "\n\e[1;32mCambiando permisos en archivos y directorios en \e[1;37m/var/www\e[0m"
find /var/www -type d -exec chmod 755 {} \;
find /var/www -type f -exec chmod 644 {} \;
# Activa mod_rewrite
a2enmod rewrite
# Activa PHP FPM
a2enmod proxy_fcgi setenvif
a2enconf php7.0-fpm
# Reiniciando Apache
systemctl restart apache2
# Firewall
echo "\n\e[1;32mConfigurando el firewall.\e[0m"
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables-save > /etc/iptables.ipv4.nat
# Configuración de interfaces de red
echo "\n\e[1;32mConfigurando interfaces de red.\e[0m"
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
# Configuracón de Hostapd
# https://wiki.gentoo.org/wiki/Hostapd
echo "\n\e[1;32mConfigurando: \e[1;37mHostapd\e[0m"
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
# Se configura para iniciar el servicio al arrancar el equipo
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd
update-rc.d hostapd enable
# Configuración de Servidor de Nombres de Dominios - DNSmasq
# https://wiki.archlinux.org/index.php/dnsmasq
echo "\n\e[1;32mConfigurando: \e[1;37mDNSmasq\e[0m"
cat > /etc/dnsmasq.conf << EOF 
domain-needed
bogus-priv
local=/aula_virtual/ 
expand-hosts
interface=wlan0
listen-address=127.0.0.1,192.168.100.1
domain=aula_virtual
no-resolv
cache-size=4096
dhcp-range=wlan0,192.168.100.100,192.168.100.150,255.255.255.0,12h
dhcp-option=option:router,192.168.100.1
dhcp-option=252,"\n"
address=/aula_virtual/192.168.100.1
EOF
# Modificación de archivo /etc/rc.local
echo "\n\e[1;32mModificando archivo: \e[1;37m/etc/rc.local\e[0m"
cat /usr/lib/NOMBRE_PROYECTO/rc.local > /etc/rc.local
sed -i "s|CAMBIAR_TEXTO|/bin/sh /usr/lib/NOMBRE_PROYECTO/instala_servicios.sh|" /etc/rc.local
# Reinicio de equipo
reboot
exit 0
FIN_ARCHIVO
###############################################################################
# Script para instalación de PostgresSQL
cat > $DIRECTORIO_TRABAJO/instala_servicios.sh << FIN_ARCHIVO
#!/bin/sh -e
# Creación de Bases de Datos
# Moodle
echo "\n\e[1;32mCreando base de datos para LMS Moodle\e[0m"
su postgres -c "psql -c \"create user USUARIO_BASE_DE_DATOS_MOODLE;\""
su postgres -c "psql -c \"alter user USUARIO_BASE_DE_DATOS_MOODLE encrypted password 'CONTRASENA_DE_USUARIO_BD_MOODLE';\""
su postgres -c "psql -c \"create database BASE_DE_DATOS_MOODLE;\""
su postgres -c "psql -c \"alter database BASE_DE_DATOS_MOODLE owner to USUARIO_BASE_DE_DATOS_MOODLE;\""
# Cambios en archivo de configuración
sed -i "s|'moodle'|'BASE_DE_DATOS_MOODLE'|" /var/www/html/config.php
sed -i "s|'username'|'USUARIO_BASE_DE_DATOS_MOODLE'|" /var/www/html/config.php
sed -i "s|'password'|'CONTRASENA_DE_USUARIO_BD_MOODLE'|" /var/www/html/config.php
sed -i "s|'/home/example/moodledata'|'RUTA_DIRECTORIO_MOODLEDATA'|" /var/www/html/config.php
sed -i "s|example.com/moodle|DOMINIO_MOODLE|" /var/www/html/config.php
# Desactivando DNSmasq
systemctl stop dnsmasq.service
# Instalación de Moodle 
/usr/bin/php /var/www/html/admin/cli/install_database.php \
   --lang=LENGUAJE_MOODLE \
   --adminuser="USUARIO_ADMIN_MOODLE" \
   --adminpass="CONTRASENA_ADMIN_MOODLE" \
   --adminemail="CORREO_ADMIN_MOODLE" \
   --fullname="NOMBRE_SITIO_MOODLE" \
   --shortname="NOMBRE_CORTO_MOODLE" \
   --agree-license 
# Se elimina el archivo inde.html
rm -f /var/www/html/index.html
# Modificación de archivo /etc/rc.local
cat /usr/lib/NOMBRE_PROYECTO/rc.local > /etc/rc.local
sed -i "s|CAMBIAR_TEXTO|/bin/sh /usr/lib/NOMBRE_PROYECTO/inicia_beacon.sh > /dev/null|" /etc/rc.local
reboot
exit 0
FIN_ARCHIVO
###############################################################################
# 7.- Cambia valores en scripts
###############################################################################
# Cambios en script de configuración de Moodle
sed -i "s|DOMINIO_MOODLE|$DOMINIO_RASPBERRY|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|LENGUAJE_MOODLE|$LENGUAJE_SITIO_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|NOMBRE_SITIO_MOODLE|$NOMBRE_COMPLETO_SITIO_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|NOMBRE_CORTO_MOODLE|$NOMBRE_CORTO_SITIO_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|CONTRASENA_ADMIN_MOODLE|$CONTRASENA_USUARIO_ADMINISTRADOR_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|USUARIO_ADMIN_MOODLE|$USUARIO_ADMINISTRADOR_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|CORREO_ADMIN_MOODLE|$CORREO_ELECTRONICO_ADMINISTRADOR_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|CONTRASENA_DE_USUARIO_BD_MOODLE|$CONTRASENA_USUARIO_BD_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|USUARIO_BASE_DE_DATOS_MOODLE|$USUARIO_BD_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|BASE_DE_DATOS_MOODLE|$BD_MOODLE|" $DIRECTORIO_TRABAJO/instala_servicios.sh
sed -i "s|RUTA_DIRECTORIO_MOODLEDATA|$RUTA_MOODLEDATA|" $DIRECTORIO_TRABAJO/instala_servicios.sh
###############################################################################
# 8.- Crea imagen para MicroSD
# Foro Raspberry Pi - http://www.raspberrypi.org/forums/viewtopic.php?f=63&t=28860
###############################################################################
crea_imagen_para_microsd(){
   # Variables para la función
   DIRECTORIO_IMAGEN_BOOT="$DIRECTORIO_TRABAJO/imagen_boot"
   DIRECTORIO_IMAGEN_ROOT="$DIRECTORIO_TRABAJO/imagen_root"
   # Crea directorios para imagenes de particiones boot y root de la microsd
   mkdir -p $DIRECTORIO_IMAGEN_BOOT
   mkdir -p $DIRECTORIO_IMAGEN_ROOT
   # Extrae valores de las particiones de la imagen de Raspbian
   SECTOR_OFFSET_BOOT=$(/sbin/fdisk -lu $ARCHIVO_RASPBIAN.img | awk '$7 == "W95" { print $2 }')
   BYTE_OFFSET_BOOT=$(expr 512 \* $SECTOR_OFFSET_BOOT)
   SECTOR_OFFSET=$(/sbin/fdisk -lu $ARCHIVO_RASPBIAN.img | awk '$7 == "Linux" { print $2 }')
   BYTE_OFFSET=$(expr 512 \* $SECTOR_OFFSET)
   ###############################################################################
   # Partición /boot de la MicroSD 
   ###############################################################################
   echo  -ne "\n\e[1;32mMontando imagen \e[0;39m/boot\e[1;32m en: \e[0;37m$DIRECTORIO_IMAGEN_BOOT\e[0m"
   echo  -ne "\n\e[1;37mSector offset \e[0;37m$SECTOR_OFFSET_BOOT \e[1;37m- Byte offset \e[0;37m$BYTE_OFFSET_BOOT\e[0m\n"
   # Montando la partición /boot
   mount -t vfat -o loop,offset=$BYTE_OFFSET_BOOT $ARCHIVO_RASPBIAN.img $DIRECTORIO_IMAGEN_BOOT
   # Añadiendo el servicio ssh al iniciar
   touch $DIRECTORIO_IMAGEN_BOOT/ssh
   # Activando USB para instalar en Raspberry Pi Zero W
   if (whiptail --title "Modelo de la Tarjeta" --yes-button "  Si  " --no-button "  No  " --defaultno --yesno "¿Utilizas Raspberry Pi Zero W?" 20 60) then
      echo "dtoverlay=dwc2" >> $DIRECTORIO_IMAGEN_BOOT/config.txt
      sed -i "s|rootwait quiet|rootwait modules-load=dwc2,g_ether quiet|" $DIRECTORIO_IMAGEN_BOOT/cmdline.txt
   fi
   # Desmontando partición /boot
   umount $DIRECTORIO_IMAGEN_BOOT
   ###############################################################################
   # Partición /root de la MicroSD 
   ###############################################################################
   echo  -ne "\n\e[1;32mMontando imagen \e[0;97m/ \e[1;32men: \e[0;37m$DIRECTORIO_IMAGEN_ROOT\e[0m"
   echo  -ne "\n\e[1;37mSector offset \e[0;37m$SECTOR_OFFSET \e[1;37m- Byte offset \e[0;37m$BYTE_OFFSET\e[0m\n"
   # Montando la partición /
   mount -t ext4 -o rw,loop,offset=$BYTE_OFFSET $ARCHIVO_RASPBIAN.img $DIRECTORIO_IMAGEN_ROOT
   # Crea directorio de scripts dentro de la imagen
   mkdir -p $DIRECTORIO_IMAGEN_ROOT/usr/lib/$NOMBRE_PROYECTO
   # Respaldo de rc.local
   cp $DIRECTORIO_IMAGEN_ROOT/etc/rc.local $DIRECTORIO_IMAGEN_ROOT/usr/lib/$NOMBRE_PROYECTO/rc.local.old
   # Copia de archivos de directorio de trabajo a imagen
   cp $DIRECTORIO_TRABAJO/rc.local $DIRECTORIO_IMAGEN_ROOT/usr/lib/$NOMBRE_PROYECTO/
   # Vuelca contenido de archivo a rc.local de la imagen 
   cat $DIRECTORIO_TRABAJO/rc.local > $DIRECTORIO_IMAGEN_ROOT/etc/rc.local
   # Copia los archivos de scripts a la imagen 
   cp $DIRECTORIO_TRABAJO/*.sh $DIRECTORIO_IMAGEN_ROOT/usr/lib/$NOMBRE_PROYECTO/
   # Sustitución del nombre del proyecto para los archivos .sh
   sed -i "s|NOMBRE_PROYECTO|$NOMBRE_PROYECTO|" $DIRECTORIO_IMAGEN_ROOT/usr/lib/$NOMBRE_PROYECTO/*.sh   
   # Permisos de ejecución para los scripts
   chmod +x $DIRECTORIO_IMAGEN_ROOT/usr/lib/$NOMBRE_PROYECTO/*.sh
   # Cambio de texto en archivo de redimensionado de particiones
   sed -i "s|Resized root filesystem\. Rebooting in 5 seconds\.\.\.|\n            A u l a   V i r t u a l   M ó v i l\n\n                            por\n\n                Comunidad Moodle México\n\n\n            http://comunidadmoodlemexico.org\n           contacto@comunidadmoodlemexico.org\n|" $DIRECTORIO_IMAGEN_ROOT/usr/lib/raspi-config/init_resize.sh
   ##############################################################################
   # Script para actualización de Paquetes - actualiza_paquetes.sh
   sed -i "s|CAMBIAR_TEXTO|/bin/sh /usr/lib/$NOMBRE_PROYECTO/actualiza_paquetes.sh|" $DIRECTORIO_IMAGEN_ROOT/etc/rc.local
   ###############################################################################
   # Script para instalación de paquetes - instala_paquetes.sh
   # TODO SE REALIZA EN ACCIONES EN LA PARTE SUPERIOR Y EN LOS PROPIOS SCRIPTS
   # Desmontando partición /
   umount $DIRECTORIO_IMAGEN_ROOT
   # Borra directorios
   rmdir $DIRECTORIO_IMAGEN_BOOT $DIRECTORIO_IMAGEN_ROOT
}
###############################################################################
# 9.- Copia imagen a MicroSD
###############################################################################
copia_imagen_a_microsd(){
   if (whiptail --title "Advertencia" --yesno "Se borrará toda la información de $UNIDAD_MICROSD." --yes-button="Continuar" --no-button="Cancelar" --defaultno 8 78) then
      # Desmonta particiones
      umount ${UNIDAD_MICROSD}{1,2} 2> /dev/null
      # Salto de línea
      echo
      # Copia de imagen a MicroSD
      if (dd if=$ARCHIVO_RASPBIAN.img of=$UNIDAD_MICROSD bs=512 conv=fsync status=progress) then
         whiptail --clear --title "Copia de imagen a MicroSD - OK" --msgbox "\n\nFavor de retirar la tarjeta MicroSD e insertarla\nen la Raspberry.\n\n\n\n                Comunidad Moodle México\n\n\n            http://comunidadmoodlemexico.org\n           contacto@comunidadmoodlemexico.org\n" 20 60
      else 
         whiptail --clear --title "Copia de imagen a MicroSD ha FALLADO" --msgbox "\n\nFavor de verificar la tarjeta MicroSD y reiniciar el proceso. Gracias.\n\n\n\n                Comunidad Moodle México\n\n\n            http://comunidadmoodlemexico.org\n           contacto@comunidadmoodlemexico.org\n" 20 60
      fi
      clear
   fi
}
###############################################################################
# 10.- Limpia y llama funciones 
###############################################################################
clear
whiptail --clear --msgbox "\n            A u l a   V i r t u a l   M ó v i l\n\n                            por\n\n                Comunidad Moodle México\n\n\n            http://comunidadmoodlemexico.org\n           contacto@comunidadmoodlemexico.org\n" 20 60
verifica_root
verifica_usb
descarga_raspbian
crea_imagen_para_microsd
copia_imagen_a_microsd
cd ~/
