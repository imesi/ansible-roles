#! /bin/bash

erro() {
    echo "formato: rstudio PORTA"
}

if [ "$1" == "" ]
then
    erro
    exit 1
fi
PORTA="$1"


USERNAME=`whoami`
PASSWORD=`pwgen -s -N 1 20`

echo "Iniciando sessão com credenciais:"
echo ""
echo "Usuário: $USERNAME"
echo "Senha: $PASSWORD"
echo ""


BASE=$HOME
mkdir -p $BASE/rstudio/run
mkdir -p $BASE/rstudio/var

RSTUDIO_SIF="/opt/apptainer/ml-verse_latest.sif"
env PASSWORD=$PASSWORD apptainer exec --nv --bind $BASE/rstudio/run:/run,$BASE/rstudio/var:/var/lib/rstudio-server,/opt/texlive:/usr/local/texlive $RSTUDIO_SIF rserver --auth-none=0 --auth-pam-helper-path=pam-helper --server-user=$(whoami) --www-port=$PORTA --www-address=127.0.0.1
