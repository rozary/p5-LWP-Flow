package LWP::Flow;

use strict;
use warnings;
use utf8;
use parent qw(LWP::UserAgent);
use Class::Accessor::Lite;
use URI::Find;
our $VERSION = '0.02';

Class::Accessor::Lite->mk_accessors(qw/except_uri/);

sub flow {
  my $self = shift;
  my $uri = shift;

  my $res = $self->get($uri);
  my $uris = $self->_flow_by_content($res->content);

  if ($self->except_uri) {
    $uris = $self->except_uri->($uris);
  }

  my $code = $self->_flow($uris);
  my $flow_res = LWP::Flow::Response->new(
    uris=>$uris,
    code=>$code,
  );
  return $flow_res;
}

sub _flow_by_content {
  my $self = shift;
  my $content = shift;

  my @links;
  my $finder = URI::Find->new(
    sub {
      my($uri,$original) = @_;
      push @links,$uri;
    },
  );
  $finder->find(\$content);

  return \@links;
}

sub _flow {
  my $self = shift;
  my $uris = shift || $self->uris || [];

  my $code = {};
  foreach my $u (@$uris) {
    my $res = $self->get($u);
    $code->{$u} = $res->code;
  }

  return $code;
}


package LWP::Flow::Response;

use strict;
use warnings;
use utf8;
use Class::Accessor::Lite;
use URI::Find;
our $VERSION = '0.02';

Class::Accessor::Lite->mk_new_and_accessors(qw/uris code/);

sub is_status{
  my $self = shift;

  return $self->_is_status(sub {
      my $code = shift;
      return grep {$_ !~ /^(1|2)\d\d/} values %$code;
    });
}

#302系も許可する
sub is_status_loose {
  my $self = shift;

  return $self->_is_status(sub {
      my $code = shift;
      return grep {$_ !~ /^(1|2|3)\d\d/} values %$code;
    });
}

sub _is_status {
  my $self = shift;
  my $CODE = shift;

  my $rtn = 0;
  return $rtn if (scalar keys %{$self->code} == 0);

  $rtn = $CODE->($self->code);
  return $rtn == 0 ? 1 : 0;
}

1;

__END__

=encoding utf-8

=head1 NAME

LWP::Flow - It's new $module

=head1 SYNOPSIS

    use LWP::Flow;

=head1 DESCRIPTION

LWP::Flow is ...

=head1 LICENSE


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Synsuke Fujishiro <i47.rozary at gmail.com>

=cut
