package HybridCross;

has 'Parent1' => (		# Parent1 seed ID.
		is =>'rw' 
		isa => 'str' 
);

has 'Parent2' => (		# Parent2 seed ID.
	is =>'rw' 
	isa => 'str' 
);

has 'F2_Wild' => (		# Number of WT plants in F2.
	is =>'rw' 
	isa => 'int' 
);

has 'F2_P1' => (		# Number of plants in F2 with a mutant gene from P1.
	is =>'rw' 
	isa => 'int' 
);

has 'F2_P2' => (		# Number of plants in F2 with a mutant gene from P2.
	is =>'rw' 
	isa => 'int' 
);

has 'F2_P1P2' => (		# Number of plants in F2 with mutant genes from both P1 and P2.
	is =>'rw' 
	isa => 'int' 
);

1;
