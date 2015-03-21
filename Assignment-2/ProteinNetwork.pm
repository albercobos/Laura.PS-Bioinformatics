package ProteinNetwork;
use Gene; use Protein; use KEGG_Term; use GO_Term;
use Moose; use strict;

# Gene Object

=head1 NAME

ProteinNetwork

=head1 DESCRIPTION

A module for representing protein networks based on protein-protein interaction.

=head1 SYNOPSIS

 use ProteinNetwork;
 my $Network = ProteinNetwork->new(Name => $name, Proteins => %ProteinObjects);

=cut

## PROPERTIES

has 'Name' =>(			# Uniprot ID
	is => 'rw',
	isa => 'Str',
	required => 1,
);


has 'Proteins' =>(			# Uniprot ID
	is => 'rw',
	isa => 'HashRef[Protein]',
);


## METHODS

1;
