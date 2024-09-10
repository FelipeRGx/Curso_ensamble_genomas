#!/bin/bash

# Crear la carpeta 'programas' y 'data' en el directorio actual
mkdir -p ~/Curso_ensamble_genomas/programas
mkdir -p ~/Curso_ensamble_genomas/data

# Definir variable BASE_DIR para la ruta de instalación
BASE_DIR=~/Curso_ensamble_genomas/programas
DATA_DIR=~/Curso_ensamble_genomas/data

# Contador para el éxito de instalaciones
total_programas=13
programas_instalados=0

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
sudo chmod +x /usr/bin/fastqc
echo 'alias fastqc="/usr/bin/fastqc"' >> ~/.bashrc

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
sudo chmod +x /usr/bin/bwa
echo 'alias bwa="/usr/bin/bwa"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de Samtools
# ----------------------------------------------
echo -n "Instalando Samtools	  ---->	"
(sudo apt-get install -y samtools > /dev/null 2>&1) & spinner
check_success "Samtools"
sudo chmod +x /usr/bin/samtools
echo 'alias samtools="/usr/bin/samtools"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de SPAdes
# ----------------------------------------------
echo -n "Instalando SPAdes	  ---->	"
(sudo apt-get install -y spades > /dev/null 2>&1) & spinner
check_success "SPAdes"
sudo chmod +x /usr/bin/spades.py
echo 'alias spades="/usr/bin/spades.py"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de Pilon
# ----------------------------------------------
echo -n "Instalando Pilon	  ---->	"
(sudo apt-get install -y pilon > /dev/null 2>&1) & spinner
check_success "Pilon"
sudo chmod +x /usr/bin/pilon
echo 'alias pilon="/usr/bin/pilon"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de Prokka
# ----------------------------------------------
echo -n "Instalando Prokka	  ---->	"
export DEBIAN_FRONTEND=noninteractive
(sudo apt-get install -y prokka > /dev/null 2>&1) & spinner
check_success "Prokka"
sudo chmod +x /usr/bin/prokka
echo 'alias prokka="/usr/bin/prokka"' >> ~/.bashrc
unset DEBIAN_FRONTEND

# ----------------------------------------------
# Instalación de BCFtools
# ----------------------------------------------
echo -n "Instalando BCFtools	  ---->	"
(sudo apt-get install -y bcftools > /dev/null 2>&1) & spinner
check_success "BCFtools"
sudo chmod +x /usr/bin/bcftools
echo 'alias bcftools="/usr/bin/bcftools"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de SRA-Toolkit
# ----------------------------------------------
echo -n "Instalando SRA-Toolkit	  ---->	"
(sudo apt-get install -y sra-toolkit > /dev/null 2>&1) & spinner
check_success "SRA-Toolkit"
echo 'alias fasterq-dump="/usr/bin/fasterq-dump"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de GATK (descarga con wget)
# ----------------------------------------------
echo -n "Instalando GATK		  ---->	"
(wget https://github.com/broadinstitute/gatk/releases/download/4.2.5.0/gatk-4.2.5.0.zip -P $BASE_DIR > /dev/null 2>&1 && unzip $BASE_DIR/gatk-4.2.5.0.zip -d $BASE_DIR > /dev/null 2>&1 && rm $BASE_DIR/gatk-4.2.5.0.zip) & spinner
check_success "GATK"
sudo chmod +x $BASE_DIR/gatk-4.2.5.0/gatk
echo 'alias gatk="'$BASE_DIR'/gatk-4.2.5.0/gatk"' >> ~/.bashrc

# ----------------------------------------------
# Instalación de QUAST desde GitHub (con corrección)
# ----------------------------------------------
echo "Instalando QUAST	  ---->	"
(git clone https://github.com/ablab/quast.git $BASE_DIR/quast > /dev/null 2>&1) & spinner


# Corrección en jsontemplate.py (cgi.escape -> html.escape)
#echo "Corrigiendo jsontemplate.py	  ---->	"
sed -i 's/cgi.escape/html.escape/g' $BASE_DIR/quast/quast_libs/site_packages/jsontemplate/jsontemplate.py
sed -i '1i import html' $BASE_DIR/quast/quast_libs/site_packages/jsontemplate/jsontemplate.py

# Instalación de dependencias y permisos
cd $BASE_DIR/quast
pip3 install -r requirements.txt > /dev/null 2>&1
sudo chmod +x quast.py
python3 setup.py install > /dev/null 2>&1

# Verificación de instalación
#echo "Verificando instalación de QUAST	  ---->	"

echo 'alias quast="'$BASE_DIR'/quast/quast.py"' >> ~/.bashrc
((programas_instalados++))
check_success "QUAST"

cd


# ----------------------------------------------
# Instalación de gdown para descargas grandes desde Google Drive
# ----------------------------------------------
echo -n "Instalando gdown	  ---->	"
(sudo pip3 install gdown > /dev/null 2>&1) & spinner
check_success "gdown\n\n\n"

# ----------------------------------------------
# Descarga de archivos desde Google Drive usando gdown
# ----------------------------------------------
echo "Descargando archivos desde Google Drive en ~/data	  ---->	"
gdown --id 1aZ6iKs-Z7HymPiVQ2t1xf-_ajj4CK-03 -O $DATA_DIR/fastq.zip
gdown --id 151PeMSeGnQJstXOvMOn8ArbbG49JIXes -O $DATA_DIR/reference.fasta

# ----------------------------------------------
# Descomprimir el archivo ZIP
# ----------------------------------------------
echo "Descomprimiendo archivo ZIP	  ---->	"
unzip $DATA_DIR/archivo1.zip -d $DATA_DIR

# ----------------------------------------------
# Resumen de la instalación
# ----------------------------------------------
echo "Instalación completada: $programas_instalados/$total_programas programas instalados correctamente."

cd
