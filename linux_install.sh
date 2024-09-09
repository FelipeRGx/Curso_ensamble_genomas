#!/bin/bash

# Crear la carpeta 'programas' en el directorio actual y carpeta 'data' para los archivos
mkdir -p ~/programas
mkdir -p ~/data

# Definir variable BASE_DIR para la ruta de instalación
BASE_DIR=~/programas
DATA_DIR=~/data

# Contador para el éxito de instalaciones
total_programas=13
programas_instalados=0

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt-get update

# ----------------------------------------------
# INSTALACIÓN DE UNZIP
# ----------------------------------------------
echo "Instalando unzip..."
if sudo apt-get install -y unzip; then
    echo "unzip instalado correctamente."
    ((programas_instalados++))
else
    echo "Error al instalar unzip."
fi

# ----------------------------------------------
# INSTALACIÓN DE FASTQC
# ----------------------------------------------
echo "Instalando FastQC..."
if sudo apt-get install -y fastqc; then
    echo "FastQC instalado correctamente."
    sudo chmod +x /usr/bin/fastqc
    echo 'alias fastqc="/usr/bin/fastqc"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar FastQC."
fi

# ----------------------------------------------
# INSTALACIÓN DE TRIMMOMATIC
# ----------------------------------------------
echo "Instalando Trimmomatic..."
if wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip -P $BASE_DIR && unzip $BASE_DIR/Trimmomatic-0.39.zip -d $BASE_DIR && rm $BASE_DIR/Trimmomatic-0.39.zip; then
    echo "Trimmomatic instalado correctamente."
    sudo chmod +x $BASE_DIR/Trimmomatic-0.39/trimmomatic-0.39.jar
    echo 'alias trimmomatic="java -jar '$BASE_DIR'/Trimmomatic-0.39/trimmomatic-0.39.jar"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar Trimmomatic."
fi

# ----------------------------------------------
# INSTALACIÓN DE BWA
# ----------------------------------------------
echo "Instalando BWA..."
if sudo apt-get install -y bwa; then
    echo "BWA instalado correctamente."
    sudo chmod +x /usr/bin/bwa
    echo 'alias bwa="/usr/bin/bwa"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar BWA."
fi

# ----------------------------------------------
# INSTALACIÓN DE SAMTOOLS
# ----------------------------------------------
echo "Instalando Samtools..."
if sudo apt-get install -y samtools; then
    echo "Samtools instalado correctamente."
    sudo chmod +x /usr/bin/samtools
    echo 'alias samtools="/usr/bin/samtools"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar Samtools."
fi

# ----------------------------------------------
# INSTALACIÓN DE SPADES
# ----------------------------------------------
echo "Instalando SPAdes..."
if sudo apt-get install -y spades; then
    echo "SPAdes instalado correctamente."
    sudo chmod +x /usr/bin/spades.py
    echo 'alias spades="/usr/bin/spades.py"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar SPAdes."
fi

# ----------------------------------------------
# INSTALACIÓN DE PILON
# ----------------------------------------------
echo "Instalando Pilon..."
if sudo apt-get install -y pilon; then
    echo "Pilon instalado correctamente."
    sudo chmod +x /usr/bin/pilon
    echo 'alias pilon="/usr/bin/pilon"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar Pilon."
fi

# ----------------------------------------------
# INSTALACIÓN DE PROKKA
# ----------------------------------------------
echo "Instalando PROKKA..."
if sudo apt-get install -y prokka; then
    echo "PROKKA instalado correctamente."
    sudo chmod +x /usr/bin/prokka
    echo 'alias prokka="/usr/bin/prokka"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar PROKKA."
fi

# ----------------------------------------------
# INSTALACIÓN DE BCFTOOLS
# ----------------------------------------------
echo "Instalando bcftools..."
if sudo apt-get install -y bcftools; then
    echo "bcftools instalado correctamente."
    sudo chmod +x /usr/bin/bcftools
    echo 'alias bcftools="/usr/bin/bcftools"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar bcftools."
fi

# ----------------------------------------------
# INSTALACIÓN DE SRA-TOOLKIT
# ----------------------------------------------
echo "Instalando SRA-Toolkit..."
if sudo apt-get install -y sra-toolkit; then
    echo "SRA-Toolkit instalado correctamente."
    echo 'alias fasterq-dump="/usr/bin/fasterq-dump"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar SRA-Toolkit."
fi

# ----------------------------------------------
# INSTALACIÓN DE GATK
# ----------------------------------------------
echo "Instalando GATK..."
if wget https://github.com/broadinstitute/gatk/releases/download/4.2.5.0/gatk-4.2.5.0.zip -P $BASE_DIR && unzip $BASE_DIR/gatk-4.2.5.0.zip -d $BASE_DIR && rm $BASE_DIR/gatk-4.2.5.0.zip; then
    echo "GATK instalado correctamente."
    sudo chmod +x $BASE_DIR/gatk-4.2.5.0/gatk
    echo 'alias gatk="'$BASE_DIR'/gatk-4.2.5.0/gatk"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar GATK."
fi

# ----------------------------------------------
# INSTALACIÓN DE QUAST DESDE GITHUB
# ----------------------------------------------
echo "Instalando QUAST..."
if git clone https://github.com/ablab/quast.git $BASE_DIR/quast && cd $BASE_DIR/quast && pip3 install --upgrade requests && sed -i 's/cte/http/g' $(grep -rl 'cte' quast/) && pip3 install -r requirements.txt && sudo chmod +x quast.py && python3 setup.py install; then
    echo "QUAST instalado correctamente."
    echo 'alias quast="'$BASE_DIR'/quast/quast.py"' >> ~/.bashrc
    ((programas_instalados++))
else
    echo "Error al instalar QUAST."
fi

# Volver al directorio original
cd ~

# ----------------------------------------------
# DESCARGA DE ARCHIVOS DE GOOGLE DRIVE
# ----------------------------------------------
echo "Descargando archivos de Google Drive en ~/data..."
# Reemplazar con la descarga de archivos de Google Drive
# Descargar archivo 1
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1aZ6iKs-Z7HymPiVQ2t1xf-_ajj4CK-03' -O $DATA_DIR/archivo1.ext
# Descargar archivo 2
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=151PeMSeGnQJstXOvMOn8ArbbG49JIXes' -O $DATA_DIR/archivo2.ext

# Actualizar y recargar bashrc para que los alias sean efectivos
source ~/.bashrc

# Resumen de la instalación
echo "Instalación completada: $programas_instalados/$total_programas programas instalados correctamente."

