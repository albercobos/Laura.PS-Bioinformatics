package AnnotatedGene;
use strict;
use Moose;
use GO_Term

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

has 'ID' => (		# Gene Locus
	is =>'rw', 
	isa => 'str', 
	required =>1,
	trigger=> \&test_ID # Tests the ID format AT#G#####
	);

has 'ProteinID' => (
	is => 'rw',
	isa => 'str',
	trigger => \&GOTermsFromLocus # Gets GO annotations on given protein
	);

has 'GO_annotation' => (	# Array of GO term codes.
	is => 'rw',
	isa => 'HashRef[GO_Term]'
	);

# METHODS

sub test_ID	{ #tests Gen_ID format

my $self = shift;
my $gene_ID= $self -> ID;

unless($gene_ID =~ /A[T|t]\d[G|g]\d{5}/){
	die "Error: The gene ID $gene_ID has the wrong format.";
}
}

sub GetProteinID{ # $gene_locus -> $UniprotID
# Gets Uniprot protein ID for a given locus name
	my $gene=$_[0];

	my $web="http://togows.dbcls.jp/search/ebi-uniprot/".$gene;
	my $protID=&get("$web");

	return $protID;
}

sub GetUniprot { # $Uniprot_ID -> @Unirprot_file
# Gets uniprot file for a protein in plain text.
	my $UniprotID=$_[0];

	my $web= 'http://togows.dbcls.jp/entry/ebi-uniprot/'.$UniprotID;
	my @UniprotFile= &get("$web");

	return @UniprotFile;
}

sub GOTermsFromLocus { # $Gene_Locus -> %GO_Terms
# Gets GO Terms for a given locus of A. thaliana.
my %GO_List;

my $self=shift;
my $locus=$self->ID;

	my $ProteinName=&GetProteinID($locus);
	my $UniprotFile=&GetUniprot($ProteinName);
	
		while ($UniprotFile=~/DR\s{3}GO;\s(GO:\d{7});/g){
			my $GOid=$1;
			my $GO_object= GO_Term -> new (
				ID => "$GOid",
				);
			$GO_list{$GOid}=$GO_object;
		}
	
	$self->GO_annotation(%GO_List);
}

1;
