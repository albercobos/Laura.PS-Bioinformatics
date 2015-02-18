package Gene;
use strict;
use Moose;

# Gene Object

has 'ID' => (		# Gene Identifier
		is =>'rw' 
		isa => 'str' 
	);

has 'Name' => (		#Name of the gene
		is =>'rw' 
		isa => 'str'
	);

	has 'Phenotype' => (		#Phenotype liked to the gene
		is =>'rw' 
		isa => 'str'
	);

1;
