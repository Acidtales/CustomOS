#!/bin/bash

# Verificar si executa amb superusuari
if [ "$(id -u)" -ne 0 ]; then
    echo "Aquest script s'ha d'executar amb superusuari."
    exit 1
fi

# Demanar el nom del usuari
echo -n "Introduir el nom d'usuari:"
read username

# Definir el directori home del usuari
user_home="/home/$username"

# Verificar si el directori d'inici del usuario existeix
if [ ! -d "$user_home" ]; then
    echo "El directori d'inici de l'usuari $username no existeix."
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
downloads_dir="$user_home/Descargas"
# Clonar, compilar e instalar bspwm i sxhkd al directori home del usuari
echo "Clonar i compilar bspwm i sxhkd al home del usuari..."
sleep 3

# Clonar los repositorios
sudo -u $username git clone https://github.com/baskerville/bspwm.git "$downloads_dir/bspwm"
sudo -u $username git clone https://github.com/baskerville/sxhkd.git "$downloads_dir/sxhkd"

# Compilar e instal·lar bspwm
echo "Compilando e instalando bspwm..."
make -C "$downloads_dir/bspwm"
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en bspwm"
    exit 1
fi
sudo make -C "$downloads_dir/bspwm" install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en bspwm"
    exit 1
fi

# Compilar e instal·lar sxhkd
echo "Compilando e instalando sxhkd..."
make -C "$downloads_dir/sxhkd"
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en sxhkd"
    exit 1
fi
sudo make -C "$downloads_dir/sxhkd" install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en sxhkd"
    exit 1
fi

sudo apt install bspwm -y
mkdir "$user_home/.config/"{bspwm,sxhkd}
mkdir "$user_home/.config/bspwm/scripts"
echo "Instalación de bspwm y sxhkd completada correctamente."

sleep 2

# Script bspwm_resize <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< REPASSAR
echo "Moviendo script bspwm_resize y el resto de configuración..."
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

echo "Instalando dependencias picom.."

sudo apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev -y
sudo apt update

# Instalar libconfig-1.7.3 desde la carpeta de trabajo actual
echo "Instalando libconfig-1.7.3 desde github"
sleep 4

cd "downloads_dir"
wget "$downloads_dir https://github.com/hyperrealm/libconfig/releases/download/v1.7.3/libconfig-1.7.3.tar.gz"
cd "$downloads_dir/libconfig-1.7.3"
tar -xvzf libconfig-1.7.3.tar.gz

# Navegar al directorio libconfig-1.7.3 (suponiendo que ya está en el directorio actual)
cd libconfig-1.7.3

# Configurar, compilar e instalar libconfig-1.7.3
./configure
if [ $? -ne 0 ]; then
    echo "Error al ejecutar ./configure en libconfig-1.7.3"
    exit 1
fi
make
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en libconfig-1.7.3"
    exit 1
fi
sudo make install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en libconfig-1.7.3"
    exit 1
fi

# Clonar el repositorio de picom en /home/ggomez/Descargas
echo "Clonando Picom en $downloads_dir..."
sudo -u $username git clone https://github.com/yshui/picom.git "$downloads_dir/picom"

# Navegar al directorio picom
cd "$downloads_dir/picom"

# Ejecutar meson setup
meson setup --buildtype=release build
if [ $? -ne 0 ]; then
    echo "Error al ejecutar meson setup en picom"
    exit 1
fi

# Ejecutar ninja build
ninja -C build
if [ $? -ne 0 ]; then
    echo "Error al ejecutar ninja en picom"
    exit 1
fi

# Ejecutar ninja build install
ninja -C build install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar ninja install en picom"
    exit 1
fi

echo "Instalación de Picom completada correctamente."

sleep 3
