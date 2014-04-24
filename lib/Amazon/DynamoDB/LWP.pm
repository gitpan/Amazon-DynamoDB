package Amazon::DynamoDB::LWP;
$Amazon::DynamoDB::LWP::VERSION = '0.08';
use strict;
use warnings;


use Future;
use LWP::UserAgent;


sub new { my $class = shift; bless {@_}, $class }


sub request {
	my $self = shift;
	my $req = shift;
	my $resp = $self->ua->request($req);
	return Future->new->done($resp->decoded_content) if $resp->is_success;

	my $status = join ' ', $resp->code, $resp->message;
	return Future->new->fail($status, $resp, $req)
}


sub ua { shift->{ua} ||= LWP::UserAgent->new(keep_alive => 10,
                                             agent => 'Amazon::DynamoDB/1.0',
                                             timeout => 90,
                                         ); }



sub delay {
    my $self = shift;
    my $amount = shift;

    Future->call(sub {
                     # Sleep could be less than one second, so use select.
                     if ($amount > 0) {
                         select(undef, undef, undef, $amount);
                     }
                     Future->new->done();
                 });
}



1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Amazon::DynamoDB::LWP

=head1 VERSION

version 0.08

=head1 DESCRIPTION

Provides a L</request> method which will use L<LWP::UserAgent> to make
requests and return a L<Future> containing the result. Used internally by
L<Amazon::DynamoDB>.

=head2 new

Instantiate.

=head2 request

Issues the request. Expects a single L<HTTP::Request> object,
and returns a L<Future> which will resolve to the decoded
response content on success, or the failure reason on failure.

=head2 ua

Returns the L<LWP::UserAgent> instance.

=head2 delay

Waits for a given interval of seconds.

Take the number of seconds to wait as a parameter.  Used for retrying requests.

=head1 NAME

Amazon::DynamoDB::LWP - make requests using L<LWP::UserAgent>

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>
Rusty Conover <rusty@luckydinosaur.com>

=head1 LICENSE

Copyright Tom Molesworth 2012-2013. Licensed under the same terms as Perl itself.
Copyright 2014 Lucky Dinosaur, LLC.

=head1 AUTHOR

Rusty Conover <rusty@luckydinosaur.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Rusty Conover.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
