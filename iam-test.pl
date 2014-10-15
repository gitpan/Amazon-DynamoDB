use strict;
use warnings;

use Amazon::DynamoDB;

my $ddb = Amazon::DynamoDB->new(
            implementation => 'Amazon::DynamoDB::LWP',
            version        => '20120810',
#	    use_iam_role   => 1,
#         access_key     => "AKIAJP5WS2SIYB3QDVTA",
#            secret_key     => "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",

   access_key => "ASIAJMRL3B4D4GAVIV3A",
   secret_key =>  "r5RdRh6u0/nGejjPjgOI8cPq/b2mMufidg5TR7zH",


            host => 'dynamodb.us-east-1.amazonaws.com',
            scope => 'us-east-1/dynamodb/aws4_request',
            ssl => 1,
		timeout => 10,
        );


my $get = $ddb->get_item(sub {
my $item = shift;
print "Got item\n";
print Data::Dumper->Dump([$item]) . "\n";
}, TableName => 'users', Key => { email => 'rusty@google.com'});
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
print Data::Dumper->Dump([$get]);

#print Data::Dumper->Dump([$ddb]) . "\n";
