package Protein;

use strict;
use Moose;
use GO_Term;
use AnnotatedGene;

# Protein objetc

=head1 NAME

Protein- a module for representing info about proteins

=head1 DESCRIPTION

This module contains information for proteins.

=head1 SYNOPSIS

 use Protein;
 my $Protein = Protein->new(Name => $name);

=cut


	## PROPERTIES ##

has 'Name' =>(			# Uniprot ID
	is => 'rw',
	isa => 'Str',
	required => 1,
	trigger => \&GetGOTerms
);

has 'Locus' =>(
	is => 'rw',
	isa => 'AnnotatedGene'
);

has 'GO_annotation' => (	# Hash of GO term codes.
	is => 'rw',
	isa => 'HashRef[GO_Term]'
	);

has 'Interactions' =>(
	is => 'rw',
	isa => 'HashRef[Protein]'
	);
 
	## METHODS ##

sub GetGOTerms { # $Gene_Locus -> %GO_Terms
# Gets GO Terms for a given locus of A. thaliana.
my %GO_List;

my $self=shift;
my $ProteinName=$self->Name;

	my $UniprotFile=&GetUniprot($ProteinName);
	
		while ($UniprotFile=~/DR\s{3}GO;\s(GO:\d{7});/g){
			my $GOid=$1;
			my $GO_object= GO_Term -> new (
				ID => "$GOid",
				);
			$GO_List{$GOid}=$GO_object;
		}
	
	$self->GO_annotation(%GO_List);
}

sub GetUniprot { # $Uniprot_ID -> @Uniprot_file
# Gets uniprot file for a protein in plain text.
	my $UniprotID=$_[0];

	my $web= 'http://togows.dbcls.jp/entry/ebi-uniprot/'.$UniprotID;
	my @UniprotFile= &get("$web");

	return @UniprotFile;
}
1;
