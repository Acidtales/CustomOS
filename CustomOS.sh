#!/bin/bash

# Verificar si executa amb superusuari
if [ "$(id -u)" -ne 0 ]; then
    echo "Aquest script s'ha d'executar amb superusuari."
    exit 1
fi

# Actualizar el sistema (Adaptat per a ParrotOS)
echo "Actualizant el sistema ParrotOS..."
sudo apt update && apt parrot-upgrade -y
if [ $? -ne 0 ]; then
    echo "Error durant l'actualizació del sistema. Cancel·lant."
    exit 1
fi

sleep 3

# Instalar dependencies
# S'ha de fer amb un "for" per detectar si falla algun paquet
echo "Instal·lant dependencies..."
apt install build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev -y

sleep 3

# Definir el directori home del usuari
echo "Definir el directori home del usuari..."
sleep 2
user_home=$(getent passwd $SUDO_USER | cut -d: -f6)

sleep 3

# Clonar, compilar e instalar bspwm i sxhkd al directori home del usuari
echo "Clonar i compilar bspwm i sxhkd al home del usuari..."

sleep 2

# Clonar los repositorios
sudo -u $SUDO_USER git clone https://github.com/baskerville/bspwm.git
sudo -u $SUDO_USER git clone https://github.com/baskerville/sxhkd.git

# Ejecutar make y make install en bspwm
make -C bspwm
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en bspwm"
    exit 1
fi
sudo make -C bspwm install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en bspwm"
    exit 1
fi

# Ejecutar make y make install en sxhkd
make -C sxhkd
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en sxhkd"
    exit 1
fi
sudo make -C sxhkd install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en sxhkd"
    exit 1
fi

sudo apt install bspwm -y

echo "Instalación de bspwm y sxhkd completada correctamente."

sleep 2

# Script bspwm_resize <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< REPASSAR

mv bspwm_resize ~/.config/bspwm/scripts

sleep 2

# Instalacion polybar

echo "Instalando Polybar.."
sudo apt install polybar -y

sleep 2

# Instalacion Picom

echo "Instalando picom.."

sudo apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev -y
sudo apt update

#!/bin/bash

# Clonar el repositorio de picom en /home/ggomez/Descargas
sudo -u $SUDO_USER git clone https://github.com/yshui/picom.git /home/ggomez/Descargas/picom

# Navegar al directorio picom
cd /home/ggomez/Descargas/picom

# Ejecutar meson setup
meson setup --buildtype=release build
if [ $? -ne 0 ]; then
    echo "Error al ejecutar meson setup en picom"
    exit 1
fi

echo "Meson setup completado correctamente en picom."

sleep 3
