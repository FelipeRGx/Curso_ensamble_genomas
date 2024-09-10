
#!/bin/bash
if [ -d "$HOME/Curso_ensamble_genomas" ]; then
  sudo rm -rf $HOME/Curso_ensamble_genomas
fi

# Crear la carpeta 'programas' y 'data' en el directorio actual del usuario
mkdir -p $HOME/Curso_ensamble_genomas/programas
mkdir -p $HOME/Curso_ensamble_genomas/data

# Definir variable BASE_DIR para la ruta de instalación
BASE_DIR=$HOME/Curso_ensamble_genomas/programas
DATA_DIR=$HOME/Curso_ensamble_genomas/data

# Contador para el éxito de instalaciones
total_programas=14
programas_instalados=0

echo "VERSION 5##%%%"


# Eliminar los alias anteriores del .zshrc
sed -i '' '/alias fastqc=/d' ~/.zshrc
sed -i '' '/alias trimmomatic=/d' ~/.zshrc
sed -i '' '/alias bwa=/d' ~/.zshrc
sed -i '' '/alias samtools=/d' ~/.zshrc
sed -i '' '/alias spades=/d' ~/.zshrc
sed -i '' '/alias pilon=/d' ~/.zshrc
sed -i '' '/alias prokka=/d' ~/.zshrc
sed -i '' '/alias bcftools=/d' ~/.zshrc
sed -i '' '/alias fasterq-dump=/d' ~/.zshrc
sed -i '' '/alias gatk=/d' ~/.zshrc
sed -i '' '/alias quast=/d' ~/.zshrc
source ~/.zshrc

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
        exit 1
    fi
}

# ----------------------------------------------
# Instalación de Homebrew (si no está instalado)
# ----------------------------------------------
if ! command -v brew &> /dev/null
then
    echo "Instalando Homebrew	  ---->	"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" & spinner

    if [ $? -ne 0 ]; then
        echo "Error al instalar Homebrew. Abortando el script."
        exit 1
    else
        echo "Homebrew instalado correctamente."
    fi
else
    echo "Homebrew ya está instalado."
fi

# Actualizar Homebrew
echo -n "Actualizando Homebrew	  ---->	"
(brew update > /dev/null 2>&1) & spinner
check_success "Homebrew update"

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
echo 'alias fastqc="/usr/local/bin/fastqc"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de Trimmomatic
# ----------------------------------------------
echo -n "Instalando Trimmomatic	  ---->	"
(brew install trimmomatic > /dev/null 2>&1) & spinner
check_success "Trimmomatic"

# ----------------------------------------------
# Instalación de BWA
# ----------------------------------------------
echo -n "Instalando BWA		  ---->	"
(brew install bwa > /dev/null 2>&1) & spinner
check_success "BWA"
echo 'alias bwa="/usr/local/bin/bwa"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de Samtools
# ----------------------------------------------
echo -n "Instalando Samtools	  ---->	"
(brew install samtools > /dev/null 2>&1) & spinner
check_success "Samtools"
echo 'alias samtools="/usr/local/bin/samtools"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de SPAdes
# ----------------------------------------------
echo -n "Instalando SPAdes	  ---->	"
(brew install spades > /dev/null 2>&1) & spinner
check_success "SPAdes"
echo 'alias spades="/usr/local/bin/spades.py"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de Pilon
# ----------------------------------------------
echo -n "Instalando Pilon	  ---->	"
(brew install pilon > /dev/null 2>&1) & spinner
check_success "Pilon"
echo 'alias pilon="/usr/local/bin/pilon"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de Prokka
# ----------------------------------------------
echo -n "Instalando Prokka	  ---->	"
(brew install prokka > /dev/null 2>&1) & spinner
check_success "Prokka"
echo 'alias prokka="/usr/local/bin/prokka"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de BCFtools
# ----------------------------------------------
echo -n "Instalando BCFtools	  ---->	"
(brew install bcftools > /dev/null 2>&1) & spinner
check_success "BCFtools"
echo 'alias bcftools="/usr/local/bin/bcftools"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de SRA-Toolkit
# ----------------------------------------------
echo -n "Instalando SRA-Toolkit	  ---->	"
(brew install sra-tools > /dev/null 2>&1) & spinner
check_success "SRA-Toolkit"
echo 'alias fasterq-dump="/usr/local/bin/fasterq-dump"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de GATK (descarga con wget)
# ----------------------------------------------
echo -n "Instalando GATK		  ---->	"
(wget https://github.com/broadinstitute/gatk/releases/download/4.2.5.0/gatk-4.2.5.0.zip -P $BASE_DIR > /dev/null 2>&1 && unzip $BASE_DIR/gatk-4.2.5.0.zip -d $BASE_DIR > /dev/null 2>&1 && rm $BASE_DIR/gatk-4.2.5.0.zip) & spinner
check_success "GATK"
chmod +x $BASE_DIR/gatk-4.2.5.0/gatk
echo 'alias gatk="'$BASE_DIR'/gatk-4.2.5.0/gatk"' >> ~/.zshrc

# ----------------------------------------------
# Instalación de QUAST desde GitHub (con corrección)
# ----------------------------------------------
echo "Instalando QUAST	  ---->	"
(git clone https://github.com/ablab/quast.git $BASE_DIR/quast > /dev/null 2>&1) & spinner

# Cambiar permisos del directorio para evitar problemas
chmod -R 755 $BASE_DIR

# Corrección en jsontemplate.py (cgi.escape -> html.escape)
sed -i '' 's/cgi.escape/html.escape/g' $BASE_DIR/quast/quast_libs/site_packages/jsontemplate/jsontemplate.py
sed -i '' '1i\
import html' $BASE_DIR/quast/quast_libs/site_packages/jsontemplate/jsontemplate.py

# Instalación de dependencias en la carpeta BASE_DIR
cd $BASE_DIR/quast
pip3 install -r requirements.txt --target=$BASE_DIR/quast_dependencies > /dev/null 2>&1

# Instalación de QUAST en BASE_DIR usando --prefix
python3 setup.py install --prefix=$BASE_DIR > /dev/null 2>&1

# Asegurar permisos de ejecución
chmod +x $BASE_DIR/quast/quast.py

# Verificación de instalación
echo 'alias quast="'$BASE_DIR'/quast/quast.py"' >> ~/.zshrc
check_success "QUAST"

# ----------------------------------------------
# Instalación de gdown para descargas grandes desde Google Drive
# ----------------------------------------------
echo -n "Instalando gdown	  ---->	"

echo -n "Instalando gdown (método 1)	  ---->	"


brew install -y python3 python3-pip  > /dev/null 2>&1
python3 -m pip install --upgrade pip
(sudo pip3 install gdown > /dev/null 2>&1) & spinner
(sudo pip install gdown --break-system-packages> /dev/null 2>&1) & spinner

python3 -m venv myenv
source myenv/bin/activate
pip install --upgrade pip
pip3 install gdown

check_success "gdown"


# Verificar si gdown está disponible después de ambos métodos
if command -v gdown &> /dev/null; then
  echo "gdown se instaló correctamente."
else
  echo "Error: ERROR NO SE  PUDO gdown."
fi

# ----------------------------------------------
# Descarga de archivos desde Google Drive usando gdown
# ----------------------------------------------
echo "Descargando archivos desde Google Drive en ~/data	  ---->	"
gdown 1aZ6iKs-Z7HymPiVQ2t1xf-_ajj4CK-03 -O $DATA_DIR/fastq.zip
gdown 151PeMSeGnQJstXOvMOn8ArbbG49JIXes -O $DATA_DIR/reference.fasta

# ----------------------------------------------
# Descomprimir el archivo ZIP
# ----------------------------------------------
echo "Descomprimiendo archivo ZIP	  ---->	"
tar -xvzf $DATA_DIR/fastq.zip -C $DATA_DIR

# Cargar el archivo .zshrc para aplicar los alias
source ~/.zshrc

# Resumen
echo "Instalación completada: $programas_instalados/$total_programas programas instalados correctamente."
