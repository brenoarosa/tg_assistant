#!/usr/bin/perl

use strict;
use warnings;
use Path::Class; #Esse modulo precisa ser instalado utilizado "sudo cpan Path::Class"
use autodie;
use POSIX;

my $dir  = dir("DB"); #Diretorio onde o arquivo que deve ser lido esta localizado
my $file = $dir->file("classification.txt"); #Arquivo contendo palavras especificas que caracterizam spam
my $spamIndex;

# Variavel que armazena o arquivo contendo as mensagens caracterizadas como spam
my $spamContent = $file->openr();

# Valida a mensagem lida com cada ocorrencia no arquivo de spams
# while(my $line = $spamContent->getline()) {
#     print $line;
# }

#Subrotina principal responsabel por chamar todas as outras validacoes e formatacoes
sub validate {
    my ($message) = @_;
    clearSpamIndex();
    $message = blankLineIntoSpace($message);
    validateMaxLengh($message);
    validateEmoticons($message);
    validadeDictionary($message);
    validateSpecialChars($message);
    #print $message;
}

# Zera o indice que verifica se a mensagem e spam ou nao
sub clearSpamIndex {
    $spamIndex = 0;
}

# Qualquer mensagem com uma pontuacao maior que 100 sera considerada spam.
sub isSpam {
    if ($spamIndex >= 600) {
        return 1;
    }
    return 0;
}

# Transfomar as quebras de linha em espacoes, o objetivo e manter toda a mensagem na mesma linha
sub blankLineIntoSpace {
    my ($message) = @_;
    $message =~ tr{\n}{ };
    return $message;
}

# Foi analizado no grupo da familia que aproximadamente 95% das mensagens nos 2 ultimos meses
# com mais de 200 caracteres sao spams, existe uma relacao do numero de caracteres de uma mensagem
# com a probabilidade dela ser ou nao spam. Tentamos modelar da seguinte forma este evento.
sub validateMaxLengh {
    my ($message) = @_;
    $spamIndex += floor(exp((length($message)*4.55)/200));
    #print $spamIndex . "\n";
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
    print $spamIndex . "\n";
}

sub validateEmoticons {
    my ($message) = @_;
    #Precisamos integrar primeiramente o c++ com o telegram para verificar como os emoticons
    #sao enviados no formato texto.
}

sub validadeDictionary {
    my ($message) = @_;
    #comparar a recorrencia de palavras na mensagem entre as palavras mais comuns utilizadas
    #em spams
}
1; #Isso e horrivel mas para eu uliziar as sub rotinas eu preciso ter essa bosta no final!