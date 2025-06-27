#!/bin/bash
#scrips que instala e atualiza texlive-full em /opt/texlive para uso com R e Rstudio do apptainer
#baseado em https://tug.org/texlive/quickinstall.html e https://tug.org/texlive/doc/tlmgr.html#EXAMPLES

#Caminho da pasta com o instalador do texlive
PASTA_INSTALADOR=/root/texliveinstalador
#URL de onde baixar o instalador do texlive
INSTALADOR_URL=https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
#Pasta de destino da instalação do texlive
DESTINO_TEXLIVE=/opt/texlive
#Prefixo da pasta com versão do instalador, é no formato AAAAMMDD, usamos só o começo
#easter egg: quando chegar nos anos 3000 vai sar algum pau esse script, altere abaixo, hahah
INSTALL_TL_PREFIXO=install-tl-2
#Lista de erros:
#1 - não criou $PASTA_INSTALADOR
#2 - não baixou $INSTALADOR_URL
#3 - não entrou $PASTA_INSTALADOR/$INSTALL_TL_PREFIXO*
#4 - não acessou $DESTINO_TEXLIVE/bin/
#5 - não conseguiu acessar pasta onde tem o atualizador em $DESTINO_TEXLIVE/bin/linux/

baixa_instalador() {
	#cria pasta, baixa o instalador e descompacta
	mkdir -p $PASTA_INSTALADOR
	cd $PASTA_INSTALADOR || exit 1
	wget $INSTALADOR_URL || exit 2
	zcat < install-tl-unx.tar.gz | tar xf -
}

instala_tex() {
	#entra na pasta onde baixou e instala no $DESTINO_TEXLIVE
	cd $PASTA_INSTALADOR/$INSTALL_TL_PREFIXO* || exit 3
	perl ./install-tl --no-interaction --texdir $DESTINO_TEXLIVE
	#cria symlink em $DESTINO_TEXLIVE/bin/ pra poder funcionar com o apptainer do R
	cd $DESTINO_TEXLIVE/bin/ || exit 4
	ln -s x86_64-linux linux
}

atualiza_tex() {
	cd $DESTINO_TEXLIVE/bin/linux/ || exit 5
	./tlmgr update --self
	./tlmgr update --list
	./tlmgr update --all --reinstall-forcibly-removed
	./mktexlsr
	echo "TexLive em $DESTINO_TEXLIVE atualizado"
}

remove_instaladores_velhos() {
	cd $PASTA_INSTALADOR || exit 1
	PASTAS_INSTALADORES=$(ls -d $INSTALL_TL_PREFIXO*/ | sort)
    	# Pega a última pasta em ordem alfabética
    	ULTIMA_PASTA=$(echo "$PASTAS_INSTALADORES" | tail -n 1)
	# Remove todas as pastas exceto a última
    	for PASTA in $PASTAS_INSTALADORES; do
        if [ "$PASTA" != "$ULTIMA_PASTA" ]; then
            rm -r "$PASTA"
        fi
    	done
}

echo "Instala ou atualiza TexLive em $DESTINO_TEXLIVE"

#verifica se NÃO EXISTE nenhuma pasta $INSTALL_TL_PREFIXO*
if ! [ -d $DESTINO_TEXLIVE/bin/linux/ ]; then
	echo "A pasta $DESTINO_TEXLIVE/bin/linux/ não existe. Baixando instalador"
	baixa_instalador
	echo "Instalando TexLive em $DESTINO_TEXLIVE"
	instala_tex
	echo "TexLive instalado em $DESTINO_TEXLIVE"
else
    	echo "Possivelmente existe instalação, procedendo com atualização"
	atualiza_tex || echo "Erro em atualizar. Verifique se a instalação estava correta"
fi
remove_instaladores_velhos
exit 0
