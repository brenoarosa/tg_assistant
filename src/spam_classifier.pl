#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use Path::Class; #Esse modulo precisa ser instalado utilizado "sudo cpan Path::Class"
use FindBin;
use lib "$FindBin::Bin/../src";
use spamModule;

my $spamIndex; #global para armazenar um indice de spam

#Subrotina principal responsabel por chamar todas as outras validacoes e formatacoes
sub validate {

    my ($message) = @_;
    clearSpamIndex();
    $message = spamModule::formatMessage($message);
    $spamIndex += spamModule::validateMaxLengh($message);
    $spamIndex += spamModule::validadeDictionary($message, $spamIndex);
    $spamIndex += spamModule::validateSpecialChars($message, $spamIndex);
    return isSpam()
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
1;