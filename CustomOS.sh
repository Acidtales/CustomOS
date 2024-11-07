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

# Definir el directori de descargas
downloads_dir="$user_home/Descargas"

# Definir el directori del repositori
REPO_ROOT="$downloads_dir/CustomOS"

# Verificar si el directori d'inici del usuario existeix
if [ ! -d "$user_home" ]; then
    echo "El directori d'inici de l'usuari $username no existeix."
    exit 1
fi

# Actualizar el sistema (Adaptat per a ParrotOS)
echo "Actualizant el sistema ParrotOS..."
sudo apt update 
#&& parrot-upgrade -y
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
echo "Instalando libconfig-1.7.3 des de GitHub"
sleep 4

# Moverse a la carpeta de descargas
cd "$downloads_dir" || { echo "Error: No se pudo acceder a $downloads_dir"; exit 1; }

# Descargar libconfig-1.7.3
wget "https://github.com/hyperrealm/libconfig/releases/download/v1.7.3/libconfig-1.7.3.tar.gz"
if [ $? -ne 0 ]; then
    echo "Error al descargar libconfig-1.7.3"
    exit 1
fi

# Descomprimir el archivo descargado
tar -xvzf libconfig-1.7.3.tar.gz
if [ $? -ne 0 ]; then
    echo "Error al descomprimir libconfig-1.7.3.tar.gz"
    exit 1
fi

# Navegar al directorio descomprimido
cd "$downloads_dir/libconfig-1.7.3" || { echo "Error: No se pudo acceder al directorio libconfig-1.7.3"; exit 1; }

# Configurar libconfig-1.7.3
./configure
if [ $? -ne 0 ]; then
    echo "Error al ejecutar ./configure en libconfig-1.7.3"
    exit 1
fi

# Compilar libconfig-1.7.3
make
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make en libconfig-1.7.3"
    exit 1
fi

# Instalar libconfig-1.7.3
sudo make install
if [ $? -ne 0 ]; then
    echo "Error al ejecutar make install en libconfig-1.7.3"
    exit 1
fi

echo "libconfig-1.7.3 instalado correctamente."

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

echo "Instalando Rofi.."
sudo apt install rofi -y
echo "Rofi instalado"
sleep 3

# Definir la URL de la fuente y el directorio de instalación
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
FONT_DIR="/usr/local/share/fonts"
ZIP_FILE="Hack.zip"

# Descargar la fuente
echo "Descargando la fuente Hack desde Nerd Fonts..."
wget -O "$FONT_DIR/$ZIP_FILE" "$FONT_URL"
if [ $? -ne 0 ]; then
    echo "Error al descargar la fuente Hack."
    exit 1
fi

# Navegar al directorio de instalación
cd "$FONT_DIR" || { echo "Error: No se pudo acceder a $FONT_DIR"; exit 1; }

# Descomprimir la fuente
echo "Descomprimiendo Hack.zip..."
sudo unzip -o "$ZIP_FILE"
if [ $? -ne 0 ]; then
    echo "Error al descomprimir Hack.zip."
    exit 1
fi

# Eliminar el archivo .zip
echo "Eliminando Hack.zip..."
sudo rm "$ZIP_FILE"
if [ $? -ne 0 ]; then
    echo "Error al eliminar Hack.zip."
    exit 1
fi

# Actualizar la caché de fuentes
echo "Actualizando la caché de fuentes..."
sudo fc-cache -fv

echo "Fuente Hack instalada correctamente."
sleep 5

# Instalar zsh
echo "Instalando zsh..."
apt update && apt install -y zsh
if [ $? -ne 0 ]; then
    echo "Error al instalar zsh."
    exit 1
fi

# Mover archivo .zshrc
echo "Moviendo archivo .zshrc a su directorio"
cp "$REPO_ROOT/.zshrc" "$user_home/"

# Definir la URL de descarga de kitty y las rutas
KITTY_URL="https://github.com/kovidgoyal/kitty/releases/download/v0.36.4/kitty-0.36.4-x86_64.txz"
KITTY_DIR="/opt/kitty"
TXZ_FILE="/tmp/kitty-0.36.4-x86_64.txz"

# Descargar kitty
echo "Descargando kitty desde GitHub..."
wget -O "$TXZ_FILE" "$KITTY_URL"
if [ $? -ne 0 ]; then
    echo "Error al descargar kitty."
    exit 1
fi

# Crear la carpeta /opt/kitty
echo "Creando el directorio /opt/kitty..."
mkdir -p "$KITTY_DIR"
if [ $? -ne 0 ]; then
    echo "Error al crear el directorio /opt/kitty."
    exit 1
fi

# Descomprimir el archivo .txz
echo "Descomprimiendo el archivo kitty-0.36.4-x86_64.txz..."
tar -xvf "$TXZ_FILE" -C "$KITTY_DIR"
if [ $? -ne 0 ]; then
    echo "Error al descomprimir kitty-0.36.4-x86_64.txz."
    exit 1
fi

# Limpieza de archivos temporales
echo "Limpiando archivos temporales..."
rm -f "$TXZ_FILE"

echo "Instalación de kitty completada correctamente."
sleep 5

# Crear el directorio de configuración de kitty si no existe
KITTY_CONFIG_DIR="$user_home/.config/kitty"
echo "Creando el directorio de configuración para kitty en $KITTY_CONFIG_DIR..."
mkdir -p "$KITTY_CONFIG_DIR"

# Mover el archivo kitty.conf al directorio de configuración
echo "Moviendo el archivo kitty.conf al directorio de configuración..."
cp "$REPO_ROOT/kitty.conf" "$KITTY_CONFIG_DIR/"
cp "$REPO_ROOT/color.ini" "$KITTY_CONFIG_DIR/"
if [ $? -ne 0 ]; then
    echo "Error al mover kitty.conf a $KITTY_CONFIG_DIR."
    exit 1
fi

# Crear el directorio de configuración de kitty al directorio de root si no existe
KITTY_ROOT_CONFIG_DIR="/root/.config/kitty"
echo "Creando el directorio de configuración de kitty para ROOT en $KITTY_ROOT_CONFIG_DIR..."
mkdir -p "$KITTY_ROOT_CONFIG_DIR"

# Mover el archivo kitty.conf al directorio del usuario root de configuración
echo "Moviendo el archivo kitty.conf al directorio de configuración de ROOT..."
cp "$REPO_ROOT/kitty.conf" "$KITTY_ROOT_CONFIG_DIR/"
cp "$REPO_ROOT/color.ini" "$KITTY_ROOT_CONFIG_DIR/"
if [ $? -ne 0 ]; then
    echo "Error al mover kitty.conf a $KITTY_ROOT_CONFIG_DIR."
    exit 1
fi
echo "Configuración de kitty completada correctamente."
sleep 2

# Instalación feh
echo "Instal·lant feh.."
apt install feh -y
echo "Instal·lació de feh compeltada"
sleep 2

# Copiar archivos polybar y fuentes
echo "Configuració polybar"

# Definir el directorio de instalación y la URL de Polybar
POLYBAR_REPO_URL="https://github.com/VaughnValle/blue-sky.git"
POLYBAR_DIR="$downloads_dir/blue-sky"
POLYBAR_CONFIG_DIR="$user_home/.config/"
FONT_DIR="/usr/share/fonts/truetype"

# Clonar el repositorio de Polybar en la carpeta de Descargas
echo "Clonando Polybar en $POLYBAR_DIR..."
sudo -u "$username" git clone "$POLYBAR_REPO_URL" "$POLYBAR_DIR"
if [ $? -ne 0 ]; then
    echo "Error al clonar el repositorio de Polybar."
    exit 1
fi

# Crear el directorio de configuración de Polybar si no existe
#echo "Creando el directorio de configuración para Polybar en $POLYBAR_CONFIG_DIR..."
#mkdir -p "$POLYBAR_CONFIG_DIR"

# Copiar el contenido del repositorio clonado a ~/.config/polybar
echo "Copiando archivos de configuración de Polybar a $POLYBAR_CONFIG_DIR..."
cp -r "$POLYBAR_DIR"/* "$POLYBAR_CONFIG_DIR/"
if [ $? -ne 0 ]; then
    echo "Error al copiar archivos de Polybar a $POLYBAR_CONFIG_DIR."
    exit 1
fi

# Copiar las fuentes a /usr/share/fonts/truetype
echo "Copiando fuentes de Polybar a $FONT_DIR..."
cp -r "$POLYBAR_DIR/polybar/fonts/"* "$FONT_DIR/"
if [ $? -ne 0 ]; then
    echo "Error al copiar las fuentes de Polybar a $FONT_DIR."
    exit 1
fi

# Actualizar la caché de fuentes
echo "Actualizando la caché de fuentes..."
fc-cache -v
echo "Instalació de Polybar completada correctament."

# Moure els scripts de la polybar a la carpeta de bspwm

SCRIPTS_DIR="$downloads_dir/CustomOS/scripts"
BSPWM_CONFIG_DIR="$user_home/.config/bspwm"

# Verificar si la carpeta "scripts" existe en el repositorio
if [ -d "$SCRIPTS_DIR" ]; then
    echo "Copiando la carpeta scripts a $BSPWM_CONFIG_DIR..."
    cp -r "$SCRIPTS_DIR" "$BSPWM_CONFIG_DIR/"
    if [ $? -ne 0 ]; then
        echo "Error al copiar la carpeta scripts a $BSPWM_CONFIG_DIR."
        exit 1
    fi
else
    echo "No se encontró la carpeta scripts en $SCRIPTS_DIR."
    exit 1
fi
echo "Carpeta scripts copiada correctament a ~/.config/bspwm."
sleep 2

# Copiar configuración polybar
echo "Copiant la configuració de la Polybar..."

REPO_POLYBAR_DIR="$downloads_dir/CustomOS/polybar"
POLYBAR_CONFIG_DIR="$user_home/.config/polybar"

# Mover y reemplazar archivos en el directorio de configuración de Polybar
echo "Moviendo archivos de $REPO_POLYBAR_DIR a $POLYBAR_CONFIG_DIR y reemplazando los existentes..."
cp -rf "$REPO_POLYBAR_DIR/"* "$POLYBAR_CONFIG_DIR/"
if [ $? -ne 0 ]; then
    echo "Error al mover y reemplazar archivos en $POLYBAR_CONFIG_DIR."
    exit 1
fi
echo "Arxius moguts correctament a ~/.config/polybar"
sleep 3

# Configurant la shell a l'usuari i root
usermod --shell /usr/bin/zsh root
usermod --shell /usr/bin/zsh admin

# link sombòlic a la configuració .zshrc
ln -s -f /home/admin/.zshrc /root/.zshrc

# canviant els persmisos a _bspc
chown root:root /usr/local/share/zsh/site-functions/_bspc

# Instal·lar plugins zsh
echo "Instal·lació plugins ZSH..."
sudo apt install zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting -y
mkdir /usr/share/zsh-sudo
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh -O /usr/share/zsh-sudo/sudo.plugin.zsh
sleep 2

# Instal·lació powerlevel10k
echo "Instal·lant la powerlevel10k a usuari i root..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$user_home/powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "/root/powerlevel10k"

cp "$downloads_dir/CustomOS/.p10k.zsh" "$user_home"
cp "$downloads_dir/CustomOS/.p10k.zsh" /root

# Instal·lar batcat
echo "Instal·lació de batcat i lsd..."
sleep 2
wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb -O "$downloads_dir/batcat.deb"
wget https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd_1.1.5_amd64.deb -O "$downloads_dir/lsd.deb"
dpkg -i "$downloads_dir/batcat.deb"
sleep 1
dpkg -i "$downloads_dir/lsd.deb"
