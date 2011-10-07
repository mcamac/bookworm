#!usr/bin/perl

#requires you to say where you're backing up to.
my $newfolder = shift @ARGV or die "Give a folder to move old files to as an input";

#First, we move the main elements to a user-specified backup location
`mv ../static ../$newfolder/static`;
`mv ../help.html ../$newfolder/`;
`mv ../about.html ../$newfolder/`;
`mv ../index.php ../$newfolder/`;

#Then, we push the main elements from this folder to the root folder.
`cp -r static ../`;
`cp help.html ../`;
`cp about.html ../`;
`cp index.php ../`;

#A few variables need to be changed:
`perl -pi -e 's/corebindings/dbbindings/gi' ../static/coffee/application.coffee`;

`perl -pi -e 's/\\/beta\\//\\//gi' ../static/coffee/application.coffee`;
`perl -pi -e 's/\\/beta\\//\\//gi' ../about.html`;


#Finally, we backup the old bindings and replace them with the new ones.
`cp /usr/lib/cgi-bin/dbbindings.py ../$newfolder/dbbindings.py`;
`cp /usr/lib/cgi-bin/corebindings.py /usr/lib/cgi-bin/dbbindings.py`;
