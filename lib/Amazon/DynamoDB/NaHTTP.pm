package Amazon::DynamoDB::NaHTTP;
$Amazon::DynamoDB::NaHTTP::VERSION = '0.002';
use strict;
use warnings;

=head1 NAME

Amazon::DynamoDB::NaHTTP - make requests using L<Net::Async::HTTP>

=head1 VERSION

version 0.002

=head1 DESCRIPTION

Provides a L</request> method which will use L<Net::Async::HTTP> to make
requests and return a L<Future> containing the result. Used internally by
L<Amazon::DynamoDB>.

=cut

use Future;
use Net::Async::HTTP 0.30;
use IO::Async::Timer::Countdown;

=head2 new

Instantiate.

=cut

sub new { 
    my $class = shift; 
    my $self = { @_ };

    defined($self->{loop}) || Carp::confess("An event loop is required");
    bless $self, $class;
}

=head2 request

Issues the request. Expects a single L<HTTP::Request> object,
and returns a L<Future> which will resolve to the decoded
response content on success, or the failure reason on failure.

=cut

sub request {
	my $self = shift;
	my $req = shift;
	my ($host, $port) = split /:/, ''.$req->uri->host_port;
	$self->ua->do_request(
		request => $req,
		host    => $host,
		port    => $port || 80,
	)->transform(
		done => sub {
			shift->decoded_content
		},
	);
}

=head2 ua

Returns a L<Net::Async::HTTP> instance.

=cut

sub ua {
	my $self = shift;
	unless($self->{ua}) {
		my $ua = Net::Async::HTTP->new(
			max_connections_per_host => 0,
			user_agent               => 'PerlAmazonDynamoDB/0.002',
			pipeline                 => 0,
			fail_on_error            => 1,
		);
		$self->{loop}->add($ua);
		$self->{ua} = $ua;
	}
	$self->{ua};
}

sub delay {
    my $self = shift;
    my $amount = shift;

    if (!$amount) {
        return Future->new->done();
    }
    
    my $future = $self->{loop}->new_future;

    $self->{loop}->watch_time(after => $amount, 
                              code => sub {
                                  $future->done();
                              });
    return $future;
}

sub loop { 
    shift->{loop}
}

1;

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>
Rusty Conover <rusty@luckydinosaur.com>

=head1 LICENSE

Copyright Tom Molesworth 2012-2013. Licensed under the same terms as Perl itself.
Copyright 2014 Lucky Dinosaur LLC.
