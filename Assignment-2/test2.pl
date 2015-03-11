use GO_Term;
use strict;
use Moose;

my$OboFile=$ARGV[0];

my %Hash=&GetGOTerms($ARGV[0]);


sub GetGOTerms{ # makes a hash of GO annotation objects, with ID numbers and term names.
my $GO_file = $_[0];

open(IN, "<$GO_file") ||
            die "can't open the input gene info file!\n";

my $GOid; my $save=0; my %GOHash;
while (my $line = <IN>) {

	if ($line=~/^id:\s(GO:\d{7})/){
		$save=1;					# $save variable is 1 until the next line, because 'name' is always in the line after id.
		$GOid=$1;
	}
	if ($save==1 and $line =~ /^name:\s(.*)$/){
		$save=0;
		my $name = $1;
		my $GO_object= GO_Term -> new (
			ID => "$GOid",
			Name => "$name"
			);
		$GOHash{$GOid}=$GO_object;
		}
}
return %GOHash;
}
