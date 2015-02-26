package Gene;
use strict;
use Moose;

# Gene Object

has 'ID' => (		# Gene Identifier
	is =>'rw', 
	isa => 'str', 
	required =>1,
	trigger=> \&test_ID # Tests the ID format AT#G#####
	);

has 'Name' => (		#Name of the gene
	is =>'rw', 
	isa => 'str'
	);

has 'Phenotype' => (		#Phenotype liked to the gene
	is =>'rw', 
	isa => 'str'
	);

has 'Linkage' =>(		# Stores the genes linked to the object
	is => 'rw',
	isa => 'ArrayRef[Gene]'
	)


sub test_ID	{ #tests Gen_ID format

my $self = shift;
my $gene_ID= $self -> ID

unless($gene_ID =~ /A[T|t]\d[G|g]\d{5}/){
	die "Error: The gene ID $gene_ID has the wrong format."
}

}

}

1;
