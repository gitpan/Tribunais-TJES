#!/usr/bin/perl -w
use strict;
use feature qw(switch say);
use CGI;
use lib "D:/wwwroot/web2.eti.br/Tribunais"; # linux - $ENV{DOCUMENT_ROOT} . "/Tribunais"
use TJES;


my $q = new CGI;

my $idprocesso = "021070011867";
my $numeracaoantiga = "021070011867";
my $numeracaonova = "021070011867";


my $edNumProcesso;
my $seInstancia=1;
my $sePesquisar=1;
if(length($numeracaonova)>1)
{
    $edNumProcesso=$numeracaonova;
}
else
{
    $edNumProcesso=$numeracaoantiga;
}

# cria o objeto TJES
#my $tribunal = new TJES($idprocesso, $edNumProcesso, $seInstancia, $sePesquisar, $URI);
my $tribunal = new Tribunais::TJES($idprocesso, $edNumProcesso, $seInstancia, $sePesquisar);

# sincroniza o processo com o TJES e pega o resultado da sincronização

#responde para o cliente em JSON
print $q->header();

print $tribunal->sincroniza;

