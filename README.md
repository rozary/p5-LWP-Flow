p5-LWP-Flow
===========

perl

# SYNOPSYS

```perl
my $ua = LWP::Flow->new;
my $res = $ua->flow($url);
my $rtn = $res->is_status; #$url先のページにあるURLに対して、ステータスコードが全て200系なら1 でなければ0
$rtn = $res->is_status_loose; #url先のページにあるURLに対して、ステータスコードが全て200系、300系なら1 でなければ0
```

