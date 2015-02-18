package SeedStock;
use strict;
use Moose;

has 'SeedID' => (		# Seed Identifier
		is =>'rw' 
		isa => 'str' 
	);

has 'MutantGene' => (		# Mutant Gene Identifier
		is =>'rw' 
		isa => 'str' 
	);

has 'LastPlanted' => (		# Last date the seed was planted
		is =>'rw' 
		isa => 'date' 
	);

has 'Storage' => (		# Place where the seed is kept
		is =>'rw' 
		isa => 'str' 
	);	

has 'GramsRemaining' => (		# Amount of seeds in stock
		is =>'rw' 
		isa => 'int' 
	);

1;
