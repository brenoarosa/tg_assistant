#!/usr/bin/perl

use strict;
use warnings;
use POSIX;

my $spamIndex; #global para armazenar um indice de spam
my $dictionary;

#Subrotina principal responsabel por chamar todas as outras validacoes e formatacoes
sub validate {

    my ($message) = @_;
    clearSpamIndex();
    my $a = floor(3.2);
    $message = formatMessage($message);
    $spamIndex += validateMaxLengh($message);
    $spamIndex += validateEmoticons($message, $spamIndex);
    $spamIndex += validateSpecialChars($message, $spamIndex);
    return isSpam();
}

# Qualquer mensagem com uma pontuacao maior que 30000 sera considerada spam.
sub isSpam {
    if ($spamIndex >= 30000) {
        return 1;
    }
    return 0;
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

# Transfomar as quebras de linha em espacoes, o objetivo e manter toda a mensagem na mesma linha
# coloca tudo minusculo
sub formatMessage {
    my ($message) = @_;
    $message =~ tr{\n}{ };
    return lc $message;
}

# Foi analizado no grupo da familia que aproximadamente 95% das mensagens nos 2 ultimos meses
# com mais de 200 caracteres sao spams, existe uma relacao do numero de caracteres de uma mensagem
# com a probabilidade dela ser ou nao spam. Tentamos modelar da seguinte forma este evento.
sub validateMaxLengh {
    my ($message) = @_;
    return floor(exp((length($message)*4.55)/200));
}

#alguns caracteres especificos sao pouco utilizados em mensagens comuns
#dificilmente e utilizado $ ! ; - @ % * _ { } ( ) e outros caracteres que serao considerados
sub validateSpecialChars {
    my ($message, $spamIndex) = @_;
    my $count = $message =~ tr/$|!|;|-|@|%|_|)|(|*|&|"|\|]|[|{|}//;
    my $ratio = $count / length($message);
    if ($ratio != 0) {
        return $spamIndex / $ratio; #corrigir isso que nao esta fazendo muito sentido quanto menor o ratio maior o numero ta errado
    }
    return 0;
}

sub validateEmoticons {
    my ($message, $spamIndex) = @_;
    #Precisamos integrar primeiramente o c++ com o telegram para verificar como os emoticons
    #sao enviados no formato texto.
}
