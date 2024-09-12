#!/bin/bash



# Crear de nuevo las carpetas
mkdir -p "$HOME/Curso_ensamble_genomas/programas"
mkdir -p "$HOME/Curso_ensamble_genomas/data"

# Definir variable BASE_DIR para la ruta de instalación
BASE_DIR=$HOME/Curso_ensamble_genomas/programas
DATA_DIR=$HOME/Curso_ensamble_genomas/data

# Contador para el éxito de instalaciones
total_programas=14
programas_instalados=0


sed -i '/alias fastqc=/d' ~/.bashrc
sed -i '/alias trimmomatic=/d' ~/.bashrc
sed -i '/alias bwa=/d' ~/.bashrc
sed -i '/alias samtools=/d' ~/.bashrc
sed -i '/alias spades=/d' ~/.bashrc
sed -i '/alias pilon=/d' ~/.bashrc
sed -i '/alias prokka=/d' ~/.bashrc
sed -i '/alias bcftools=/d' ~/.bashrc
sed -i '/alias fasterq-dump=/d' ~/.bashrc
sed -i '/alias gatk=/d' ~/.bashrc
sed -i '/alias quast=/d' ~/.bashrc
source ~/.bashrc

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

# ----------------------------------------------
# Actualizar el sistema en modo silencioso
# ----------------------------------------------
sudo apt-get update -y > /dev/null 2>&1
echo "Sistema actualizado correctamente."

# ----------------------------------------------
# Instalación de unzip
# ----------------------------------------------
echo -n "Instalando unzip	  ---->	"
(sudo apt-get install -y unzip > /dev/null 2>&1) & spinner
check_success "unzip"

# ----------------------------------------------
# Instalación de FastQC
# ----------------------------------------------
echo -n "Instalando FastQC	  ---->	"
(sudo apt-get install -y fastqc > /dev/null 2>&1) & spinner
check_success "FastQC"

# ----------------------------------------------
# Instalación de Trimmomatic (descarga con wget)
# ----------------------------------------------
echo -n "Instalando Trimmomatic	  ---->	"
(wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip -P $BASE_DIR > /dev/null 2>&1 && unzip $BASE_DIR/Trimmomatic-0.39.zip -d $BASE_DIR > /dev/null 2>&1 && rm $BASE_DIR/Trimmomatic-0.39.zip) & spinner
check_success "Trimmomatic"
sudo chmod +x $BASE_DIR/Trimmomatic-0.39/trimmomatic-0.39.jar
echo 'alias trimmomatic="java -jar '$BASE_DIR'/Trimmomatic-0.39/trimmomatic-0.39.jar"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de BWA
# ----------------------------------------------
echo -n "Instalando BWA		  ---->	"
(sudo apt-get install -y bwa > /dev/null 2>&1) & spinner
check_success "BWA"

# ----------------------------------------------
# Instalación de Samtools
# ----------------------------------------------
echo -n "Instalando Samtools	  ---->	"
(sudo apt-get install -y samtools > /dev/null 2>&1) & spinner
check_success "Samtools"

# ----------------------------------------------
# Instalación de SPAdes
# ----------------------------------------------
echo -n "Instalando SPAdes	  ---->	"
(sudo apt-get install -y spades > /dev/null 2>&1) & spinner
check_success "SPAdes"

# ----------------------------------------------
# Instalación de Pilon
# ----------------------------------------------
echo -n "Instalando Pilon	  ---->	"
(sudo apt-get install -y pilon > /dev/null 2>&1) & spinner
check_success "Pilon"

# ----------------------------------------------
# Instalación de Prokka
# ----------------------------------------------
echo -n "Instalando Prokka	  ---->	"
sudo apt-get install debconf-utils > /dev/null 2>&1

export DEBIAN_FRONTEND=noninteractive
(sudo apt-get install -y prokka > /dev/null 2>&1) & spinner
check_success "Prokka"
unset DEBIAN_FRONTEND


# ----------------------------------------------
# Instalación de BCFtools
# ----------------------------------------------
echo -n "Instalando BCFtools	  ---->	"
(sudo apt-get install -y bcftools > /dev/null 2>&1) & spinner
check_success "BCFtools"

# ----------------------------------------------
# Instalación de SRA-Toolkit
# ----------------------------------------------
echo -n "Instalando SRA-Toolkit	  ---->	"
(sudo apt-get install -y sra-toolkit > /dev/null 2>&1) & spinner
check_success "SRA-Toolkit"

# ----------------------------------------------
# Instalación de GATK (descarga con wget)
# ----------------------------------------------
echo "Instalando QUAST	  ---->	"

# Función para verificar si el archivo .status existe
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
        sudo rm -rf "$dir"
    fi
}

# Función para marcar éxito en .status
mark_status_success() {
    local dir=$1
    echo "true" | sudo tee "$dir/.status" > /dev/null
}


# Función para eliminar directorio si falla la instalación
delete_directory_if_failed() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo "Eliminando la carpeta $dir debido a un error..."
        sudo rm -rf "$dir"
    fi
}

########################################
# Instalación de QUAST
########################################
QUAST_DIR="$BASE_DIR/quast"
echo "Verificando QUAST..."

# Eliminar la carpeta si ya existe pero no tiene el archivo .status
delete_if_no_status $QUAST_DIR

if check_status_file $QUAST_DIR; then
    echo "QUAST ya está instalado correctamente."
else
    echo "Instalando QUAST..."
    (sudo apt-get update > /dev/null 2>&1) & spinner
    (sudo apt-get install -y pkg-config libfreetype6-dev libpng-dev python3-matplotlib > /dev/null 2>&1) & spinner

    # Número máximo de reintentos
    max_retries=3
    retry_count=0
    success=false

    # Intentar descargar QUAST hasta el máximo número de intentos
    while [ $retry_count -lt $max_retries ]; do
        echo "Descargando QUAST desde https://github.com/ablab/quast.git..."
        if sudo git clone --progress https://github.com/ablab/quast.git $QUAST_DIR 2>&1 | tee >(grep "Compressing objects\|Receiving objects"); then
            # Aplicar permisos a toda la carpeta
            sudo chmod -R 755 $QUAST_DIR
            success=true
            break
        else
            retry_count=$((retry_count+1))
            sleep 5 # Esperar 5 segundos antes de reintentar
        fi
    done

    if [ "$success" = true ]; then
        echo "Descarga de QUAST exitosa."

        # Verificar si el archivo requirements.txt existe
        
        # Corrección en jsontemplate.py (cgi.escape -> html.escape)
        sudo sed -i 's/cgi.escape/html.escape/g' $QUAST_DIR/quast_libs/site_packages/jsontemplate/jsontemplate.py > /dev/null 2>&1
        sudo sed -i '1i import html' $QUAST_DIR/quast_libs/site_packages/jsontemplate/jsontemplate.py > /dev/null 2>&1

        # Instalación de dependencias y permisos
        cd $QUAST_DIR
        sudo chmod +x quast.py > /dev/null 2>&1
        sudo python3 ./setup.py install > /dev/null 2>&1

        # Añadir alias para QUAST
        echo 'alias quast="'$QUAST_DIR'/quast.py"' >> ~/.bashrc
        source ~/.bashrc  # Recargar el archivo de configuración

        # Marcar como éxito
        sudo mark_status_success $QUAST_DIR
        echo "QUAST instalado correctamente."
    else
        echo -e "\e[31mError en tu conexión. Inténtalo más tarde.\e[0m"
        delete_directory_if_failed $QUAST_DIR
        exit 1
    fi
fi

########################################
# Instalación de GATK
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

        # Añadir alias para GATK
        echo 'alias gatk="'$GATK_DIR'/gatk"' >> ~/.bashrc
        source ~/.bashrc  # Recargar el archivo de configuración

        # Marcar como éxito
        mark_status_success $GATK_DIR
        echo "GATK instalado correctamente."
    else
        echo -e "\e[31mError en tu conexión. Inténtalo más tarde.\e[0m"
        delete_directory_if_failed $GATK_DIR
        exit 1
    fi
fi

# ----------------------------------------------
# Instalación de gdown para descargas grandes desde Google Drive
# ----------------------------------------------
echo -n "Instalando dependencias	  ---->	"
sudo apt-get update -y > /dev/null 2>&1
sudo apt install -y python3 python3-pip > /dev/null 2>&1
python3 -m pip install --upgrade pip > /dev/null 2>&1
echo "Dependencias instaladas correctamente."

# ----------------------------------------------
# Descarga de archivos desde Dropbox
# ----------------------------------------------
echo "Descargando archivos desde Dropbox en ~/data	  ---->	"

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
sudo tar -xvzf $DATA_DIR/fastq.zip -C $DATA_DIR

# Verificar si la descompresión fue exitosa
if [ $? -eq 0 ]; then
    echo "Archivo ZIP descomprimido correctamente."
else
    echo -e "\e[31mError al descomprimir el archivo ZIP.\e[0m"
    exit 1
fi
