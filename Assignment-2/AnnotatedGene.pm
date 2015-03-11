package AnnotatedGene;
use strict;
use Moose;

# Gene Object

=head1 NAME

Gene - a module for representing info about genes

=head1 DESCRIPTION

This module contains information like the Gene locus identifier and annotations related.

=head1 SYNOPSIS

 use Gene;
 my $Gene = Gene->new(Gene_Name => $name, ID => $ID);

=cut

# PROPERTIES

has 'ID' => (		# Gene Identifier
	is =>'rw', 
	isa => 'str', 
	required =>1,
	trigger=> \&test_ID # Tests the ID format AT#G#####
	);

has 'GO_annotation' => (	# Array of GO term codes.
	is => 'rw',
	isa => 'ArrayRef[GO_Term]'
	);

# METHODS

sub test_ID	{ #tests Gen_ID format

my $self = shift;
my $gene_ID= $self -> ID;

unless($gene_ID =~ /A[T|t]\d[G|g]\d{5}/){
	die "Error: The gene ID $gene_ID has the wrong format.";
}

}

1;
