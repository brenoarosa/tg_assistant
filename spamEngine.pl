#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use Path::Class; #Esse modulo precisa ser instalado utilizado "sudo cpan Path::Class"
use POSIX;

my $spamIndex; #global para armazenar um indice de spam

#Subrotina principal responsabel por chamar todas as outras validacoes e formatacoes
sub validate {
    my ($message) = @_;
    clearSpamIndex();
    $message = formatMessage($message);
    validateMaxLengh($message);
    validateEmoticons($message);
    validadeDictionary($message);
    validateSpecialChars($message);
    return isSpam();
}

# Zera o indice que verifica se a mensagem e spam ou nao
sub clearSpamIndex {
    $spamIndex = 0;
}

# Qualquer mensagem com uma pontuacao maior que 30000 sera considerada spam.
sub isSpam {
    if ($spamIndex >= 30000) {
        return 1;
    }
    return 0;
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
    $spamIndex += floor(exp((length($message)*4.55)/200));
}

#alguns caracteres especificos sao pouco utilizados em mensagens comuns
#dificilmente e utilizado $ ! ; - @ % * _ { } ( ) e outros caracteres que serao considerados
sub validateSpecialChars {
    my ($message) = @_;
    my $count = $message =~ tr/$|!|;|-|@|%|_|)|(|*|&|"|\|]|[|{|}//;
    my $ratio = $count / length($message);
    if ($ratio != 0) {
        $spamIndex += $spamIndex / $ratio;
    }
}

# Sera feito na integracao com o c++ e o telegram
sub validateEmoticons {
    my ($message) = @_;
    #Precisamos integrar primeiramente o c++ com o telegram para verificar como os emoticons
    #sao enviados no formato texto.
}

#Compara a utilizacao de palavras com palavras comuns em um dicionario de frases mas utilizadas
#em spams
sub validadeDictionary {
    my ($message) = @_;
    my $dir  = dir("DB"); #Diretorio onde o arquivo que deve ser lido esta localizado
    my $file = $dir->file("classification.txt"); #Arquivo contendo palavras especificas que caracterizam spam
    # Variavel que armazena o arquivo contendo as mensagens caracterizadas como spam
    my $spamContent = $file->openr();
    my $count = 0;
    while(my $line = $spamContent->getline()) {
        my $word = lc $line;
        chomp($word);
        $count += $message =~ /$word/g;
    }
    $spamIndex += $spamIndex ** ($count);
}
1; #Isso e horrivel mas para eu uliziar as sub rotinas eu preciso ter essa bosta no final!