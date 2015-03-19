package KEGG_Term;
use strict;
use Moose;

# KEGG annotation objetc

=head1 NAME

KEGG_Term - a module for representing info about KEGG annotation terms

=head1 DESCRIPTION

This module contains information for gene annotation from KEGG.

=head1 SYNOPSIS

 use KEGG_Term;
 my $KEGG = KEGG_Term->new(ID => $ID, Name => $Name);

=cut

# PROPERTIES

has 'ID' => (		# GO Identifier
	is =>'rw', 
	isa => 'Str', 
	required =>1,
	);

has 'Name' => ( # Name of the GO term
	is => 'rw',
	isa => 'Str'
	);



1;
