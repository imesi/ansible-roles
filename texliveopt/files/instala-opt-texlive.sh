#!/bin/bash
#scrips que instala e atualiza texlive-full em /opt/texlive para uso com R e Rstudio do apptainer
#baseado em https://tug.org/texlive/quickinstall.html e https://tug.org/texlive/doc/tlmgr.html#EXAMPLES
#Utilize esse script para Instalar ou Atualizar texlive em /opt/texlive pronto para ser utilizado com Apptainer, 
#Porém:
#Instalação do zero: cerca de 90 minutos em ótimo hardware. Por enquanto preferimos executar manualmente.
#Supondo que já tenha uma instalação atualizada em brucutuvii:
#O mais rápido do zero: ssh root@brucutuvii.ime.usp.br "( cd /opt ; tar --zstd -cf - texlive;)" | tar --zstd -xf -
#O mais rápido para atualizar: rsync -a root@brucutuvii.ime.usp.br:/opt/texlive /opt/
#Tar com zstd ~ 1minuto em ótima máquina.
#Rsync completo: 1m30s (bem menos pra atualização apenas) em ótima máquina.
#ótima máquina: 1Gbps R7 série 5000 com bastante RAM e NVMe. BrucutuVII Threadripper série 7000 com muita RAM e NVMe.
#TODO: incluir um "case" para escolher a forma de instalar ou atualizar escolhendo a origem.
#Sugestão para TODO: Perguntar se quer instalar/atualizar da fonte ou instalar/atualizar de ORIGEM.

#Caminho da pasta com o instalador do texlive
PASTA_INSTALADOR=/root/texliveinstalador
#URL de onde baixar o instalador do texlive
INSTALADOR_URL=https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
#Pasta de destino da instalação do texlive
DESTINO_TEXLIVE=/opt/texlive
#Prefixo da pasta com versão do instalador, é no formato AAAAMMDD, usamos só o começo
#easter egg: quando chegar nos anos 3000 vai dar algum pau nesse script, altere abaixo, hahah
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
	wget $INSTALADOR_URL -O install-tl-unx.tar.gz || exit 2
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

echo "Instala ou atualiza TexLive em $DESTINO_TEXLIVE. Baixando instalador mais recente"
baixa_instalador
echo "Removendo instaladores antigos antes da instalação"
remove_instaladores_velhos

#verifica se NÃO EXISTE nenhuma pasta $INSTALL_TL_PREFIXO*
if ! [ -d $DESTINO_TEXLIVE/bin/linux/ ]; then
	echo "A pasta $DESTINO_TEXLIVE/bin/linux/ não existe."
	echo "Instalando TexLive em $DESTINO_TEXLIVE"
	instala_tex
	echo "TexLive instalado em $DESTINO_TEXLIVE"
else
  echo "Possivelmente já existe instalação, procedendo com atualização"
	atualiza_tex || echo "Erro em atualizar. Verifique se a instalação estava correta"
fi
exit 0
