#!/usr/bin/perl

require "./spamEngine.pl";
use strict;
use warnings;
use Path::Class; #Esse modulo precisa ser instalado utilizado "sudo cpan Path::Class"
use autodie;

my $dir  = dir("DB"); #Diretorio onde o arquivo que deve ser lido esta localizado
my $file = $dir->file("messages.txt"); #Arquivo contendo varias mensagens do grupo da familia

# Variavel que armazena o arquivo contendo as mensagens caracterizadas como spam
my $messages = $file->openr();
my $message  = "";
# Valida a mensagem lida com cada ocorrencia no arquivo de spams
while(my $line = $messages->getline()) {
    #Separador de mensagem, no trabalho final como cada mensagem sera inviada individualmente nao sera preciso.
    if ($line ne "==========\n") {
        $message .= $line;
    } else {
        validate($message);
        $message = ""; #Zera a mensagem quando ela chega ao separador e inicaliza uma nova vazia
    }
}

