#!/usr/bin/perl

# Netflix ratings downloader
# Version 1.1, 9/9/2012
# Written by Casey Duquette
#
# Description:
# This tool will screen-scrape the netflix web page that shows your ratings.
# The pit-fall with using their API and currently all other people's tools,
# is that it will only give you the ratings for movies that netflix knows
# you have watched (ie instant play or dvd). They do not (at this time) have 
# a function to simply get your ratings. The developer must get a list of 
# movies you have watched and for each movie, get your rating. If you rated
# a movie you saw elsewhere, then tough nuggets. This will literally,
# download the same web page you see on your computer and go page by page
# saving all the movies and ratings you saved. These ratings will be dumped
# into a nice CSV file for you. The netflix movie id is included in case in 
# the future you wish to import these ratings to another account. This script
# works with their updated site as of the initial version.
#
# Change log:
# 09-07-2012: Initial version
# 09-09-2012: Handles multi user accounts
#

use CGI;
use strict;
use WWW::Mechanize;
use HTTP::Cookies;
use Crypt::SSLeay;

###########################################################################################
###################### CONFIGURABLE ITEMS #################################################
###########################################################################################

   # Netflix sign in page
   my $url_signin = "https://signup.netflix.com/login";

   # Credentials
   my $email = '';
   my $password = "";

   # Handles if user wants another person's data that is on their account (families)
   my $getAllUsers = 0;				# If 1, downloads each users' data to separate files
   my $queueName = "Casey Duquette";	# If you don't want all users, which specific user to get

   # Output csv file, root file name, no extension. User name will be tacked on
   my $outputfile = "netflix-ratings-full";

   # Include movie release year and average community rating? Will considerably slow it down
   my $includeyear = 1;

###########################################################################################
####### DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ####################
###########################################################################################

# Create the virtual browser
my $mech = WWW::Mechanize->new(timeout=>3);
my $mech2 = WWW::Mechanize->new();	# Download individual movie info

# Create the place to store cookies and tell our browser to use it
unlink("cookies");
my $cookie_jar = HTTP::Cookies->new(File => "cookies", autosave =>1);
$mech->cookie_jar($cookie_jar);

# Test if netflix is up because timeout doesn't seem to work with https page
$mech->get("http://www.netflix.com");

# Get the login page
$mech->get($url_signin);

# Checks if login is required or we can move on
if ( $mech->content() =~ /id="login-form"/ ) {
	$mech->form_id('login-form');
	$mech->field(email => $email);
	$mech->field(password => $password);
	$mech->submit();
}

# Did login not work?
if ( $mech->content() =~ /id="login-form"/ ) {
	die "Login information incorrect\n";
}

# If not getting all users, go to the queue desired
if ($getAllUsers == 0) {
	if ( $mech->find_link( text => "$queueName" ) != undef ) {
		# Is user link a javascript link? Because that means it is current user
		if ( $mech->find_link( text => "$queueName" )->url() !~ /^javascript/ ) {
			# Different user, go to their acct
			$mech->follow_link( text => "$queueName", n => 1 );
		}
		$outputfile = $outputfile."-".$queueName.".csv";
	} else {
		die "Could not find account for \"$queueName\"\n";
	}
}

# Prepare the output file for writing
open RATINGS, ">", $outputfile or die "Could not open $outputfile: $!\n";

# Print column headers
print RATINGS "\"ID\",\"Title\",\"Year\",\"My Rating\",\"Avg Rating\",\"URL\"\n";

# After the login page, navigate to the ratings page
$mech->follow_link(text => "What You've Rated", n => 1);

my $movies;		# Holds all the movie information we find
my $cur = 1;	# Keep track of the page we are on, only used to display progress
my $moviecount = 0;	# Keep track of number of ratings for display and confirmation at end

# Loops through each page
do {
	my $content = $mech->content(); # Get content of page
	
	# For each movie row on the page
	while ( $content =~ /<tr class="agMovie(.*?)<\/tr>/gsi ) {
		my $movierow = $1;
		my $movieid;
	
		# Get the url to the movie details
		if ( $movierow =~ /href="([^"]+)"/ ) {
		
			my $movieurl = $1;
			#print "Link: $1\n";
			
			# Get netflix's movie ID from the URL
			if ( $movieurl =~ /\/(\d+?)\?/ ) {
				#print "Movie ID: $1\n";
				$movies->{$1}->{url} = $movieurl;
				$movieid = $1;
			} else {
				die "Couldn't find movie ID for $movieurl\n";
			}
		}
		
		# Get the movie title (link text)
		if ( $movierow =~ /<a.*?>\s*([^<]+?)\s*<\/a>/ ) {
			#print "Title: $1\n";
			print "$1\n";
			$movies->{$movieid}->{title} = $1;
		}
		
		# Get the rating
		if ( $movierow =~ /you rated this movie: (\d+)/i ) {
			#print "Rating: $1\n";
			$movies->{$movieid}->{rating} = $1;
		}
		
		# Get the year of the movie if available
		$movies->{$movieid}->{year} = "";
		$movies->{$movieid}->{avgrating} = "";
		if ( $includeyear == 1) {
			$mech2->get($movies->{$movieid}->{url});
			if ( $mech2->content() =~ /<span class="year".*?(\d+)<\/span>/gsi ) {
				$movies->{$movieid}->{year} = $1;
			}
			if ( $mech2->content() =~ /average of.*?([\d.]+)\s+stars/gsi ) {
				$movies->{$movieid}->{avgrating} = $1;
			}
		}
		
		print RATINGS "\"$movieid\",\"$movies->{$movieid}->{title}\",\"$movies->{$movieid}->{year}\",\"$movies->{$movieid}->{rating}\",\"$movies->{$movieid}->{avgrating}\",\"$movies->{$movieid}->{url}\"\n";
		
		$moviecount++;
	}
	
	$cur++;
	print "\nDownloading page $cur\n\n";
	
} while ( $mech->find_link( text => "next" ) != undef && $mech->follow_link(text => "next", n => 1) );

close RATINGS;

print "Done! Saved $moviecount ratings.\n\n";

