#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use Path::Class; #Esse modulo precisa ser instalado utilizado "sudo cpan Path::Class"
use lib "/home/igor/Desktop/UFRJ/Class/Linguagem de Programacao/Trabalho/Modulo/"; #Modificar o path para o diretorio em que o modulo se encontra
use spamModule;

my $spamIndex; #global para armazenar um indice de spam
my $dictionary;

#Subrotina principal responsabel por chamar todas as outras validacoes e formatacoes
sub validate {

    my ($message) = @_;
    clearSpamIndex();
    setDictionary();
    $message = spamModule::formatMessage($message);
    $spamIndex += spamModule::validateMaxLengh($message);
    $spamIndex += spamModule::validateEmoticons($message, $spamIndex);
    $spamIndex += spamModule::validadeDictionary($message, $dictionary, $spamIndex);
    $spamIndex += spamModule::validateSpecialChars($message, $spamIndex);
    print isSpam();
}

# Zera o indice que verifica se a mensagem e spam ou nao
sub clearSpamIndex {
    $spamIndex = 0;
}

sub setDictionary {
    my $dir  = dir("DB"); #Diretorio onde o arquivo que deve ser lido esta localizado
    $dictionary = $dir->file("classification.txt"); #Arquivo contendo palavras especificas que caracterizam spam
    # Variavel que armazena o arquivo contendo as mensagens caracterizadas como spam
}

# Qualquer mensagem com uma pontuacao maior que 30000 sera considerada spam.
sub isSpam {
    if ($spamIndex >= 30000) {
        return 1;
    }
    return 0;
}


# Foi analizado no grupo da familia que aproximadamente 95% das mensagens nos 2 ultimos meses
# com mais de 200 caracteres sao spams, existe uma relacao do numero de caracteres de uma mensagem
# com a probabilidade dela ser ou nao spam. Tentamos modelar da seguinte forma este evento.
sub validateMaxLengh {
    my ($message) = @_;
    $spamIndex += floor(exp((length($message)*4.55)/200));
}


1; #Isso e horrivel mas para eu uliziar as sub rotinas eu preciso ter essa bosta no final!