package Protein;

use strict;
use Moose; use LWP::Simple;
use GO_Term; use Gene; use KEGG_Term;


# Protein objetc

=head1 NAME

Protein- a module for representing info about proteins

=head1 DESCRIPTION

This module contains information for proteins and several subroutines to get that information from the web.

=head1 SYNOPSIS

 use Protein;
 my $Protein = Protein->new(Name => $name);

=cut


	## PROPERTIES ##

has 'Name' =>(			# Uniprot ID
	is => 'rw',
	isa => 'Str',
	required => 1,
	trigger => \&GetProteinInfo
);

has 'Locus' =>(
	is => 'rw',
	isa => 'Gene'
);

has 'GO_annotation' => (	# Hash of GO term codes.
	is => 'rw',
	isa => 'HashRef[GO_Term]'
	);

has 'KEGG_annotation' => (	# Hash of GO term codes.
	is => 'rw',
	isa => 'HashRef[KEGG_Term]'
	);

has 'Interactions' =>(
	is => 'rw',
	isa => 'Array'
	);
 
	## METHODS ##

sub GetProteinInfo { # $Protein Name -> GO & KEGG annotations and Biogrid interaction info.
# Gets GO Terms, KEGG Terms and interaction information from BioGrid for a given locus of A. thaliana.
my %GO_List; my %KEGG_List; my @Interactors;

my $self=shift;
my $ProteinName=$_[0]; my $Synonym;
if ($ProteinName=~/^(\w*)_ARATH/){$Synonym=$1;}

	my $UniprotFile=get("http://togows.dbcls.jp/entry/uniprot/".$ProteinName."/dr.json");
	my $json = JSON->new; 
	my $ref_content = $json->decode( $UniprotFile );
	
	my $refs = $ref_content->[0]; # an array with only one member… a hash-ref!

my $GO_annots = $refs->{GO};
my $KEGG_annots= $refs->{KEGG};
my $BioGrid_annots= $refs->{BioGrid};


foreach my $annotation (@{$GO_annots}){ # Creates GO annotation objects
	my $GO_object= GO_Term -> new (
		ID => "$annotation->[0]",
		Name => "$annotation->[1]"
	);
	$GO_List{$annotation->[0]}=$GO_object;
}
$self->GO_annotation(%GO_List);
	
foreach my $annotation (@{$KEGG_annots}){ # Creates KEGG annotation objects
	my $KEGG_object= KEGG_Term -> new (
		ID => "$annotation->[0]",
		Name => "$annotation->[1]"
	);
	$KEGG_List{$annotation->[0]}=$KEGG_object;
}
$self->KEGG_annotation(%KEGG_List);
	
foreach my $annotation (@{$BioGrid_annots}){
    @Interactors=&SearchBioGrid($annotation->[0],$ProteinName,$Synonym);
}

$self->Interactions(@Interactors);
}


sub SearchBioGrid{ #looks for protein-protein interactions, gives an array of proteins that interact with query protein.

	my $key="edd249da4bf37ca8fb9eb608c1fedb57";
	my $interactionID=$_[0]; my $ProteinName=$_[1]; my $Synonym=$_[2];
	my @Interactors;
	my $url="http://webservice.thebiogrid.org/interactions/?geneList=$interactionID&searchBiogridIds=true&includeInteractors=true&accesskey=$key&format=jsonExtended";
	my $s = get($url);

	my $json = JSON->new; 
	my $perl_scalar = $json->decode( $s );

	foreach my $key(keys %$perl_scalar){

		my $type = $perl_scalar->{$key}->{'EXPERIMENTAL_SYSTEM'};

		next if $type =~ /affinity/i; # Only use co-localization and fractionation or two-hybrid data
		next if $type =~ /pca/i; 
		next unless ($type =~ /localization/i || $type =~ /fractionation/i || $type =~ /hybrid/);
		
		# Compare Biogrid protein names to our protein name to find interactors
		
		if (($perl_scalar->{$key}->{'OFFICIAL_SYMBOL_A'} eq $ProteinName or $perl_scalar->{$key}->{'OFFICIAL_SYMBOL_A'} eq $Synonym) and $perl_scalar->{$key}->{'OFFICIAL_SYMBOL_B'} ne $ProteinName and $perl_scalar->{$key}->{'OFFICIAL_SYMBOL_B'} ne $Synonym){			
			push (@Interactors,$perl_scalar->{$key}->{'OFFICIAL_SYMBOL_B'});
			next;
		}elsif($perl_scalar->{$key}->{'OFFICIAL_SYMBOL_B'} eq $ProteinName or $perl_scalar->{$key}->{'OFFICIAL_SYMBOL_B'} eq $Synonym and $perl_scalar->{$key}->{'OFFICIAL_SYMBOL_A'} ne $ProteinName and $perl_scalar->{$key}->{'OFFICIAL_SYMBOL_A'} ne $Synonym){
			my $interactor=$perl_scalar->{$key}->{'OFFICIAL_SYMBOL_A'};
			push (@Interactors,$perl_scalar->{$key}->{'OFFICIAL_SYMBOL_A'});
			next;
		}
		
		
	}
	return @Interactors;
}
1;
