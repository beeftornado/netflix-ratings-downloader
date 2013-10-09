#!/usr/bin/perl

use LWP;

# Netflix sign in page
my $url_signin = "https://signup.netflix.com/login";

# Create virtual "browser"
my $browser = LWP::UserAgent->new;

# Enable in-memory cookies (erased when script ends)
$browser->cookie_jar({});

# Follow redirects for POST requests (after login)
push @{ $browser->requests_redirectable }, 'POST';

# Try to access signin page
my $response = $browser->get($url_signin);
checkResponse($response, $url_signin);

# Get token code from login page to pass along with form submission
if ($response->content =~ m/name="authURL" value="([^"]+)"/) {
	print "Found authURL value to be $1\n";
	my $authURL = $1;
} else {
	die "Could not find the authURL to include with login";
}

# Login and get session cookie
$response = $browser->post($url_signin,
	[
		"email" => 'xxxxxx@gmail.com',
		"password" => "",
		"authURL" => "$authURL",
		"RememberMe" => "true"
	]
);
checkResponse($response, $url_signin);

# Print source
print $response->content;
print "\n";

sub checkResponse() {
	my ($response, $url) = @_;
	
	# Check if succeeded in getting page
	die "Can't get $url -- ", $response->status_line unless $response->is_success;

	# Check returned content type
	die "Hey, I was expecting HTML, not ", $response->content_type unless $response->content_type eq 'text/html';
}