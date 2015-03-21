package Gene;

use Moose;
use Protein; 

# Gene Object

=head1 NAME

Gene - a module for representing info about genes

=head1 DESCRIPTION

This module contains information like the Gene locus identifier and annotations related.

=head1 SYNOPSIS

 use Gene;
 my $Gene = Gene->new(Name => $name, ID => $ID);

=cut

# PROPERTIES

has 'ID' => (		# Gene Locus
	is =>'rw', 
	isa => 'Str', 
	required =>1,
	trigger=> \&test_ID # Tests the ID format AT#G#####
	);

# METHODS

sub test_ID	{ #tests Gen_ID format

my $self = shift;
my $gene_ID= $self -> ID;

unless($gene_ID =~ /A[T|t]\d[G|g]\d{5}/){
	die "Error: The gene ID $gene_ID has the wrong format.";
}
}

sub CreateProtein{ # @gene_locus -> %Protein_Objects . Gets protein names from a locus and creates a hash of protein objects.
	my $GeneHash=$_[0];
	my @proteins; my %ProteinHash;

	foreach my $gene (keys %$GeneHash){

		my $locus=$GeneHash->{$gene}->{ID};
		my $web="http://togows.dbcls.jp/search/ebi-uniprot/"."$locus";
		my $protID=&LWP::Simple::get("$web");

		if ($protID =~/([\w|_]+)/g){
			 push(@proteins, $1);
		}
		foreach my $name(@proteins){
			my $Synonym;
			if ($name=~/^(\w*)_ARATH/){$Synonym=$1;}
			my $ProteinObject=Protein->new(
			Name=>"$name",
			Synonym=>"$Synonym",
			Locus=>"$locus"
			);
		$ProteinHash{$name}=$ProteinObject;
		}
	}
return \%ProteinHash;
}

1;
