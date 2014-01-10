package LWP::Flow;

use strict;
use warnings;
use parent qw(LWP::UserAgent);
use utf8;
use URI::Find;
use Mouse;
our $VERSION = '0.01';

has "user" => (is=>"rw");
has "pass" => (is=>"rw");
has "referer" => (is=>"rw");
has "except_uri" => (is=>"rw");

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
use URI::Find;
use Mouse;
our $VERSION = '0.01';

has "uris" => (is=>"rw",required=>1);
has "code" => (is=>"rw",required=>1);

sub is_status{
  my $self = shift;

  my $code = $self->code;
  my $rtn = grep {$_ !~ /^(1|2)\d\d/} values %$code;
  return $rtn ? 0 : 1;
}

#302系も許可する
sub is_status_loose {
  my $self = shift;

  my $code = $self->code;
  my $rtn = grep {$_ !~ /^(?:1|2|3)\d\d/} values %$code;
  return $rtn ? 0 : 1;
}

1;
