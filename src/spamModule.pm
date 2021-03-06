#!/usr/bin/perl

package spamModule;
# Para esse modulo funcionar, execute um export PER5LIB=<Caminho completo do modulo>
# exemplo export PER5LIB=/home/igor/Desktop/UFRJ/Class/Linguagem de Programacao/Trabalho/Modulo
use strict;
use warnings;
use POSIX;
use Path::Class; #Esse modulo precisa ser instalado utilizado "sudo cpan Path::Class"

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
        return $spamIndex / $ratio;
    }
    return 0;
}

#Compara a utilizacao de palavras com palavras comuns em um dicionario de frases mas utilizadas
#em spams
sub validadeDictionary {
    my ($message, $spamIndex) = @_;
    my $count = 0;
    my $file = "classification.txt";
    open my $info, $file or die "Could not open $file: $!";

    while (my $line = <$info>) {
        my $word = lc $line;
        chomp($word);
        $count += $message =~ /$word/g;
    }
    return $spamIndex ** ($count);
}
1;