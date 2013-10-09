netflix-ratings-downloader
==========================

Small script that saves your Netflix® ratings to a CSV file. I couldn't find something that reliably worked for me when I canceled my account so I wrote this.

It is likely to break because of the methodology it uses. Netflix has an API for getting your ratings, but it will only serve back ratings for movies you rented from them. If you're like me, who went through and rated all kinds of movies you saw before Netflix® so you could get better recommendations, then this may help you.

Requirements
------------
perl >= 5.10 (may work on previous versions)

perl modules:
* CGI
* strict
* WWW::Mechanize
* HTTP::Cookies
* Crypt::SSLeay

And I have only used this on my OSX system, but I suspect it works on Linux as well.

Use
---

```
perl download_rating_data.pl
```
And then you should see some output indicating that the ratings are being processed. Afterwards, you should see a csv file named `netflix-ratings-full-<your_name>.csv`

If you open it either in a regular text editor, or Excel, you will see something similar to this

```
"ID","Title","Year","My Rating","Avg Rating","URL"
"70221573","Doctor Who: The End of Time","2009","5","4.6","http://movies.netflix.com/WiMovie/Doctor_Who_The_End_of_Time/70221573?trkid=496715"
"1057618","Total Recall","1990","5","3.6","http://movies.netflix.com/WiMovie/Total_Recall/1057618?trkid=496715"
"70136138","The X-Files","2001","5","4","http://movies.netflix.com/WiMovie/The_X-Files/70136138?trkid=496715"
"70136139","Hannah Montana","2010","5","3.3","http://movies.netflix.com/WiMovie/Hannah_Montana/70136139?trkid=496715"
"60027493","Cube 2: Hypercube","2002","5","3.1","http://movies.netflix.com/WiMovie/Cube_2_Hypercube/60027493?trkid=496715"
"70136124","30 Rock","2012","5","3.9","http://movies.netflix.com/WiMovie/30_Rock/70136124?trkid=496715"
"17672318","12 Monkeys","1995","5","3.7","http://movies.netflix.com/WiMovie/12_Monkeys/17672318?trkid=496715"
```

As you can see, it will save Netflix®'s movie ID, title, release year, your rating, average Netflix® rating, and the Netflix® movie url.

How it works
------------
It works by logging in to your Netflix® account, and using a technique known as "web-scraping." This is where the HTML of your movie ratings is analyzed, and the ratings are extracted from it. This is the same reason it is likely to break. Programs that use "web-scraping" are heavily dependent on the website's HTML, which may change often.

Contributing
------------
Contributions are welcome. I only spent a few hours on this the night before my account closed so it isn't pretty or very user friendly. I hope to make some minor adjustments because I'm open sourcing it, but nothing major. If it stops working due to a site change, I'd be happy to update this to work, but I no longer have an active account. If someone else has the expertise then by all means, go ahead and patch it up and send it to me.

Ideas
-----
* Add rating restore functionality. If you want to transfer ratings.
* Get off perl? I like python...or maybe ruby would be a good choice...
