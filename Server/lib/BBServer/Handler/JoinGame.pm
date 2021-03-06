# vim:ts=4:sw=4:expandtab
package BBServer::Handler::JoinGame;

use strict;
use parent qw(BBServer::Handler::Base);
use List::Util qw(shuffle);
use JSON::XS;
use Data::Dumper;
use Game;
use Games;
use v5.10;
our $VERSION = '0.01';
__PACKAGE__->asynchronous(1);

sub handle_request {
    my ($self, $request, $token) = @_;

    return $self->error('No token') unless defined($token);
    return $self->error('Game ID missing') unless exists $request->{id};

    my $player = Players->instance->by_token($token);

    my $game = Games->instance->by_id($request->{id});
    return $self->error('No such game') unless defined($game);

    # Even if we fail, we just continue. The player can have the words again,
    # if he wants to. (Makes reload handling in JavaScript easier)
    $game->add_player($player);

    return { size => $game->size, words => [ shuffle(@{$game->words}) ] };
}

1
