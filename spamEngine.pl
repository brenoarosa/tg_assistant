#!/usr/bin/perl

use strict;
use warnings;
use Path::Class; #Esse modulo precisa ser instalado utilizado "sudo cpan Path::Class"
use autodie;

my $dir  = dir("DB"); #Diretorio onde o arquivo que deve ser lido esta localizado
my $file = $dir->file("classification.txt"); #Arquivo contendo palavras especificas que caracterizam spam

# Variavel que armazena o arquivo contendo as mensagens caracterizadas como spam
my $spamContent = $file->openr();

# Valida a mensagem lida com cada ocorrencia no arquivo de spams
# while(my $line = $spamContent->getline()) {
#     print $line;
# }

#Subrotina principal responsabel por chamar todas as outras validacoes e formatacoes
sub validate {
    my ($message) = @_;
    $message = blankLineIntoSpace($message);
    validateMaxLengh($message);
    #print $message;
}

# Transfomar as quebras de linha em espacoes, o objetivo e manter toda a mensagem na mesma linha
sub blankLineIntoSpace {
    my ($message) = @_;
    $message =~ tr{\n}{ };
    return $message;
}

# Foi analizado no grupo da familia que aproximadamente 95% das mensagens nos 2 ultimos meses
# com mais de 200 caracteres sao spams
sub validateMaxLengh {
    my ($message) = @_;
    print length($message) . "\n";
}

#sub para verificar acentuacao
#sub para verificar emoticons
#sub para verificar no dicionario


1; #Isso e horrivel mas para eu uliziar as sub rotinas eu preciso ter essa bosta no final!