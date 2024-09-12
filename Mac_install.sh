#!/bin/bash

sudo su

# Crear de nuevo las carpetas
mkdir -p "$HOME/Curso_ensamble_genomas/programas"
mkdir -p "$HOME/Curso_ensamble_genomas/data"

# Verificar si existe el enlace simbólico para python en macOS
if [ ! -e /usr/local/bin/python ]; then
    echo "Creando enlace simbólico para python3 como python en macOS"
    sudo ln -s /usr/local/bin/python3 /usr/local/bin/python
else
    echo "El enlace simbólico para python ya existe en macOS."
fi

# Definir variable BASE_DIR para la ruta de instalación
BASE_DIR=$HOME/Curso_ensamble_genomas/programas
DATA_DIR=$HOME/Curso_ensamble_genomas/data

# Contador para el éxito de instalaciones
total_programas=14
programas_instalados=0

# Determinar cuál archivo de configuración usar para los alias
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
else
    SHELL_CONFIG="$HOME/.bashrc"  # Para shells bash antiguos
fi

# Eliminar alias antiguos
sed -i '' '/alias fastqc=/d' $SHELL_CONFIG
sed -i '' '/alias trimmomatic=/d' $SHELL_CONFIG
sed -i '' '/alias bwa=/d' $SHELL_CONFIG
sed -i '' '/alias samtools=/d' $SHELL_CONFIG
sed -i '' '/alias spades=/d' $SHELL_CONFIG
sed -i '' '/alias pilon=/d' $SHELL_CONFIG
sed -i '' '/alias prokka=/d' $SHELL_CONFIG
sed -i '' '/alias bcftools=/d' $SHELL_CONFIG
sed -i '' '/alias fasterq-dump=/d' $SHELL_CONFIG
sed -i '' '/alias gatk=/d' $SHELL_CONFIG
sed -i '' '/alias quast=/d' $SHELL_CONFIG
source $SHELL_CONFIG

echo "VERSION 5##%%%"

# Spinner de carga
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Función para verificar si un comando fue exitoso
check_success() {
    if [ $? -eq 0 ]; then
        ((programas_instalados++))
        echo "$1 instalado correctamente."
    else
        echo "Error al instalar $1."
    fi
}

echo "Actualizando Homebrew y el sistema..."
if [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi
brew update > /dev/null 2>&1
echo "Sistema actualizado correctamente."

# ----------------------------------------------
# Actualizar el sistema en modo silencioso
# ----------------------------------------------
echo "Actualizando Homebrew y el sistema..."
sudo brew update > /dev/null 2>&1
echo "Sistema actualizado correctamente."

# ----------------------------------------------
# Instalación de unzip
# ----------------------------------------------
echo -n "Instalando unzip	  ---->	"
(brew install unzip > /dev/null 2>&1) & spinner
check_success "unzip"

# ----------------------------------------------
# Instalación de FastQC
# ----------------------------------------------
echo -n "Instalando FastQC	  ---->	"
(brew install fastqc > /dev/null 2>&1) & spinner
check_success "FastQC"

# ----------------------------------------------
# Instalación de Trimmomatic (descarga con wget)
# ----------------------------------------------
echo -n "Instalando Trimmomatic	  ---->	"
echo -n "Instalando Trimmomatic	  ---->	"
(brew install trimmomatic > /dev/null 2>&1) & spinner
check_success "Trimmomatic"

# ----------------------------------------------
# Instalación de BWA
# ----------------------------------------------
echo -n "Instalando BWA		  ---->	"
(brew install bwa > /dev/null 2>&1) & spinner
check_success "BWA"

# ----------------------------------------------
# Instalación de Samtools
# ----------------------------------------------
echo -n "Instalando Samtools	  ---->	"
(brew install samtools > /dev/null 2>&1) & spinner
check_success "Samtools"

# ----------------------------------------------
# Instalación de SPAdes
# ----------------------------------------------
echo -n "Instalando SPAdes	  ---->	"
(brew install spades > /dev/null 2>&1) & spinner
check_success "SPAdes"

# ----------------------------------------------
# Instalación de Pilon
# ----------------------------------------------
echo -n "Instalando Pilon	  ---->	"
(brew install pilon > /dev/null 2>&1) & spinner
check_success "Pilon"

# ----------------------------------------------
# Instalación de Prokka
# ----------------------------------------------
echo -n "Instalando Prokka	  ---->	"
brew tap brewsci/bio > /dev/null 2>&1
(brew install prokka > /dev/null 2>&1) & spinner
check_success "Prokka"

# ----------------------------------------------
# Instalación de BCFtools
# ----------------------------------------------
echo -n "Instalando BCFtools	  ---->	"
(brew install bcftools > /dev/null 2>&1) & spinner
check_success "BCFtools"

# ----------------------------------------------
# Instalación de SRA-Toolkit
# ----------------------------------------------
echo -n "Instalando SRA-Toolkit	  ---->	"
(brew install sratoolkit > /dev/null 2>&1) & spinner
check_success "SRA-Toolkit"

check_status_file() {
    local dir=$1
    if [ -f "$dir/.status" ] && grep -q "true" "$dir/.status"; then
        return 0
    else
        return 1
    fi
}

# Función para eliminar directorio si no existe el archivo .status
delete_if_no_status() {
    local dir=$1
    if [ -d "$dir" ] && [ ! -f "$dir/.status" ]; then
        echo "Eliminando la carpeta $dir porque no tiene un archivo .status."
        sudo rm -rf "$dir" > /dev/null 2>&1
    fi
}

# Función para marcar éxito en .status
mark_status_success() {
    local dir=$1
    sudo touch "$dir/.status" > /dev/null
}

# Función para eliminar directorio si falla la instalación
delete_directory_if_failed() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo "Eliminando la carpeta $dir debido a un error..."
        sudo rm -rf "$dir" > /dev/null 2>&1
    fi
}

########################################
# Instalación de QUAST (macOS)
########################################
QUAST_DIR="$BASE_DIR/quast"
echo "Verificando QUAST..."

# Eliminar la carpeta si ya existe pero no tiene el archivo .status
delete_if_no_status $QUAST_DIR

if check_status_file $QUAST_DIR; then
    echo "QUAST ya está instalado correctamente."
else
    echo "Instalando QUAST..."
    (brew update > /dev/null 2>&1) & spinner
    (brew install pkg-config freetype libpng python-matplotlib > /dev/null 2>&1) & spinner

    # Número máximo de reintentos
    max_retries=3
    retry_count=0
    success=false

    # Intentar descargar QUAST hasta el máximo número de intentos
    while [ $retry_count -lt $max_retries ]; do
        echo "Descargando QUAST desde https://github.com/ablab/quast.git..."
        
        # Verificar si la carpeta sigue existiendo sin archivo .status y eliminarla
        delete_if_no_status $QUAST_DIR
        
        if git clone --progress https://github.com/ablab/quast.git $QUAST_DIR 2>&1 | tee >(grep "Compressing objects\|Receiving objects"); then
            # Aplicar permisos a toda la carpeta
            sudo chmod -R 755 $QUAST_DIR
            success=true
            break
        else
            retry_count=$((retry_count+1))
            sleep 15 # Esperar 15 segundos antes de reintentar
        fi
    done

    if [ "$success" = true ]; then
        echo "Descarga de QUAST exitosa."

        # Verificar si el archivo jsontemplate.py existe y hacer corrección
        if [ -f "$QUAST_DIR/quast_libs/site_packages/jsontemplate/jsontemplate.py" ]; then
            sudo sed -i '' 's/cgi.escape/html.escape/g' $QUAST_DIR/quast_libs/site_packages/jsontemplate/jsontemplate.py > /dev/null 2>&1
            sudo sed -i '' '1i import html' $QUAST_DIR/quast_libs/site_packages/jsontemplate/jsontemplate.py > /dev/null 2>&1
        fi

        # Instalación de dependencias y permisos
        cd $QUAST_DIR
        sudo chmod +x quast.py
        sudo python3 ./setup.py install > /dev/null 2>&1

        # Añadir alias para QUAST en el shell de macOS
        echo 'alias quast="'$QUAST_DIR'/quast.py"' >> ~/.zshrc
        source ~/.zshrc  # Recargar el archivo de configuración

        # Marcar como éxito
        mark_status_success $QUAST_DIR
        echo "QUAST instalado correctamente."
    else
        echo -e "\e[31mError en tu conexión. Inténtalo más tarde.\e[0m"
        delete_directory_if_failed $QUAST_DIR
        exit 1
    fi
fi

########################################
# Instalación de GATK (macOS)
########################################
GATK_DIR="$BASE_DIR/gatk-4.2.5.0"
echo "Verificando GATK..."

# Eliminar la carpeta si ya existe pero no tiene el archivo .status
delete_if_no_status $GATK_DIR

if check_status_file $GATK_DIR; then
    echo "GATK ya está instalado correctamente."
else
    echo "Instalando GATK..."

    # Restablecer los contadores para GATK
    retry_count=0
    success=false

    # Intentar descargar GATK hasta el máximo número de intentos
    while [ $retry_count -lt $max_retries ]; do
        echo "Descargando GATK..."
        if wget --progress=dot:giga https://github.com/broadinstitute/gatk/releases/download/4.2.5.0/gatk-4.2.5.0.zip -P $BASE_DIR 2>&1 | grep -o -E "([0-9]+%)"; then
            success=true
            break
        else
            retry_count=$((retry_count+1))
            sleep 5 # Esperar 5 segundos antes de reintentar
        fi
    done

    if [ "$success" = true ]; then
        # Descomprimir el archivo descargado
        unzip $BASE_DIR/gatk-4.2.5.0.zip -d $BASE_DIR > /dev/null 2>&1

        # Verificar si el archivo gatk existe
        if [ ! -f "$GATK_DIR/gatk" ]; then
            echo "Error: No se encuentra el archivo ejecutable gatk"
            delete_directory_if_failed $GATK_DIR
            exit 1
        fi

        # Eliminar el archivo zip después de la descompresión
        rm $BASE_DIR/gatk-4.2.5.0.zip > /dev/null 2>&1

        # Asignar permisos de ejecución
        sudo chmod -R 755 $GATK_DIR > /dev/null 2>&1

        # Añadir alias para GATK en el shell de macOS
        echo 'alias gatk="'$GATK_DIR'/gatk"' >> ~/.zshrc
        source ~/.zshrc  # Recargar el archivo de configuración

        # Marcar como éxito
        mark_status_success $GATK_DIR
        echo "GATK instalado correctamente."
    else
        echo -e "\e[31mError en tu conexión. Inténtalo más tarde.\e[0m"
        delete_directory_if_failed $GATK_DIR
        exit 1
    fi
fi

echo "Descargando archivos desde Dropbox en ~/data	  ---->	"

# Verificar si wget está instalado
if ! command -v wget &> /dev/null; then
    echo "Instalando wget..."
    brew install wget > /dev/null 2>&1
fi

# Descargar fastq.zip
wget -O $DATA_DIR/fastq.zip "https://www.dropbox.com/scl/fi/07yop16imcdkdgtfqmabf/fastq.zip?rlkey=m65e9u15w4d640hbnm1ci6xgv&st=afk913km&dl=1"

# Descargar reference.fasta
wget -O $DATA_DIR/reference.fasta "https://www.dropbox.com/scl/fi/gvq2qvamu0iegjkgemy54/reference.fasta?rlkey=4b3d4exwea2tgrlhyu6n61zd7&st=rcjv34gr&dl=1"

# Verificar si los archivos se descargaron correctamente
if [[ -f "$DATA_DIR/fastq.zip" && -f "$DATA_DIR/reference.fasta" ]]; then
    echo "Archivos descargados correctamente desde Dropbox."
else
    echo -e "\e[31mError en la descarga de los archivos desde Dropbox.\e[0m"
    exit 1
fi

# ----------------------------------------------
# Descomprimir el archivo ZIP
# ----------------------------------------------
echo "Descomprimiendo archivo ZIP	  ---->	"
sudo tar -xvzf $DATA_DIR/fastq.zip -C $DATA_DIR > /dev/null 2>&1

# Verificar si la descompresión fue exitosa
if [ $? -eq 0 ]; then
    echo "Archivo ZIP descomprimido correctamente."
else
    echo -e "\e[31mError al descomprimir el archivo ZIP.\e[0m"
    exit 1
fi
