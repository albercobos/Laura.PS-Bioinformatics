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

unless($GO_ID =~ /[GO|Go|go]:\s\d{7}/){
	die "Error: The GO ID $GO_ID has the wrong format.";
}

}
1;
