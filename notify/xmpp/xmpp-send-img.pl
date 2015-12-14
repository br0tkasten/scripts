#!/usr/bin/perl

use Config::General;
use Net::XMPP;
use LWP::UserAgent;
use File::Basename;
use Data::Dumper;
use strict;

my ($tojid,$filename) = @ARGV; 

my $conf = Config::General->new("$ENV{HOME}/.xmpprc");
my %config = $conf->getall;

my $client = new Net::XMPP::Client();
$client->SetCallBacks( iq => \&iq_cb );
$client->AddNamespace(
	ns => 'urn:xmpp:http:upload',
	tag => 'slot',
	xpath => {
		Get => { path => 'get/text()' },
		Put => { path => 'put/text()' },
	}
);

my $status = $client->Connect( 
	hostname => $config{server}, 
	port     => $config{port}, 
	tls      => 0,
);
die("EE - connect($config{server}:$config{port}): failed or connection not allowed\n") unless($status);


my ($auth_status,$auth_error) = eval {$client->AuthSend( 
	username => $config{username},
	password => $config{password},
	resource => $config{resource}
)};
die("EE - Authorization failed: $auth_status - $auth_error\n") unless($auth_status eq 'ok');


my $fileName = basename($filename);
my $fileSize = -s $filename;

my $query = qq{
<iq from='$config{username}\@$config{server}/$config{resource}' to='$config{server}' type='get'>
	<request xmlns='urn:xmpp:http:upload'>
		<filename>$fileName</filename>
		<size>$fileSize</size>
	</request>
</iq>
};

my $id = $client->SendWithID($query);
$client->Process(1);

sub iq_cb {
	my ($id,$iq) = @_;
	my $query = $iq->GetQuery();

	my $imageData;
	open(IMG,"<$filename");
	binmode IMG;
	read(IMG,$imageData,$fileSize);
	close(IMG);

	my $ua = LWP::UserAgent->new(ssl_opts => { 
        	verify_hostname => 0, 
    	});
	$ua->timeout(600);
	my $putRequest = HTTP::Request->new(PUT => $query->GetPut());
	$putRequest->content($imageData);
	my $response = $ua->request($putRequest);

	if($response->is_success) {
		$client->MessageSend( 
			to => $tojid,
			body => $query->GetGet()
		);
	} else {
		print $response->decoded_content . "\n";
	}
}

$client->Disconnect();
