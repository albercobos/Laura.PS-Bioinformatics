package GO_Term;
use strict;
use Moose;

# Gene Object

=head1 NAME

GO_Term - a module for representing info about GO annotation terms

=head1 DESCRIPTION

This module contains information for gene annotation from Gene Ontology.

=head1 SYNOPSIS

 use GO_Term;
 my $GO = GO_Term->new(ID => $ID, Name => $Name);

=cut

# PROPERTIES

has 'ID' => (		# GO Identifier
	is =>'rw', 
	isa => 'Str', 
	required =>1,
	trigger=> \&test_GO_ID # Tests the ID format GO:#######
	);

has 'Name' => ( # Name of the GO term
	is => 'rw',
	isa => 'Str'
	);

# METHODS

sub test_GO_ID	{ #tests GO_ID format

my $self = shift;
my $GO_ID= $self -> ID;

unless($GO_ID =~ /[GO|Go|go]:\d{7}/){
	die "Error: The GO ID $GO_ID has the wrong format.";
}

sub GetAllGOTerms{ # makes a hash of GO annotation objects, with all ID numbers and term names within an .obo file.
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

sub GetMyGOTerms{ # Gets GO term names from a given list of GO IDs. 
my ($GOHashRef, $OboFile)=@_;
my %GOHash=%{$GOHashRef};

open(IN, "<$OboFile") ||
            die "can't open the input gene info file!\n";

my $save=0;
while (my $line = <IN>) {
	
	foreach my $GOid (keys %GOHash){
		if ($line=~/^id:\s$GOid/){
			$save=1;					# $save variable is 1 until the next line, because 'name' is always in the line after id.
		}
		if ($save==1 and $line =~ /^name:\s(.*)$/){
			$save=0;
			my $name = $1;
			%GOHash{$GOid}->Name($name);
		}
	}
}

}

1;
