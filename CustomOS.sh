#!/bin/bash

# Verificar si executa amb superusuari
if [ "$(id -u)" -ne 0 ]; then
    echo "Aquest script s'ha d'executar amb superusuari."
    exit 1
fi

# Actualizar el sistema (Adaptat per a ParrotOS)
echo "Actualizant el sistema ParrotOS..."
sudo apt update && parrot-upgrade -y
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
if [ -z "$SUDO_USER" ]; then
    user_home=$HOME
else
    user_home=$(eval echo ~$SUDO_USER)
fi
# Crear el directori Descargas si no existeix
mkdir -p "$user_home/Descargas"

# Clonar, compilar e instalar bspwm i sxhkd al directori home del usuari
echo "Clonar i compilar bspwm i sxhkd al home del usuari..."
sleep 3

# Clonar los repositorios
sudo -u $SUDO_USER git clone https://github.com/baskerville/bspwm.git "$user_home/Descargas/"
sudo -u $SUDO_USER git clone https://github.com/baskerville/sxhkd.git "$user_home/Descargas/"

# Compilar e instal·lar bspwm
echo "Compilando e instalando bspwm..."
make -C "$user_home/Descargas/bspwm"
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en bspwm"
    exit 1
fi
sudo make -C "$user_home/Descargas/bspwm" install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en bspwm"
    exit 1
fi

# Compilar e instal·lar sxhkd
echo "Compilando e instalando sxhkd..."
make -C "$user_home/Descargas/sxhkd"
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en sxhkd"
    exit 1
fi
sudo make -C "$user_home/Descargas/sxhkd" install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en sxhkd"
    exit 1
fi

sudo apt install bspwm -y

echo "Instalación de bspwm y sxhkd completada correctamente."

sleep 2

# Script bspwm_resize <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< REPASSAR
mkdir "$user_home/.config/bspwm/scripts"
cp bspwm_resize "$user_home/.config/bspwm/scripts"
cp bspwmrc "$user_home/.config/bspwm/"
cp sxhkdrc "$user_home/.config/sxhkd/"
echo "Scripts y configuracion movida a sus directorios.."
sleep 2

# Instalacion polybar

echo "Instalando Polybar.."
sudo apt install polybar -y

sleep 2

# Instalacion Picom

echo "Instalando picom.."

sudo apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev -y
sudo apt update

# Clonar el repositorio de picom en /home/ggomez/Descargas
sudo -u $SUDO_USER git clone https://github.com/yshui/picom.git "$user_home/Descargas"/

# Navegar al directorio picom
cd "$user_home/Descargas/picom"

# Ejecutar meson setup
meson setup --buildtype=release build
if [ $? -ne 0 ]; then
    echo "Error al ejecutar meson setup en picom"
    exit 1
fi

echo "Meson setup completado correctamente en picom."

sleep 3
