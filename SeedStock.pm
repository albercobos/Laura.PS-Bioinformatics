package SeedStock;
use strict;
use Moose;

has 'SeedID' => (		# Seed Identifier
	is =>'rw',
	isa => 'str', 
	required =>1
	);

has 'MutantGene' => (		# Mutant Gene Identifier
	is =>'rw',
	isa => 'Gene',
	required=>1
	);

has 'LastPlanted' => (		# Last date the seed was planted
	is =>'rw', 
	isa => 'date'
	);

has 'Storage' => (		# Place where the seed is kept
	is =>'rw', 
	isa => 'str'
	);	

has 'GramsRemaining' => (		# Amount of seeds in stock
	is =>'rw',
	isa => 'int',
	required =>1,
	default=>0 #If any value is given, the amount is set to zero.
	);

1;
