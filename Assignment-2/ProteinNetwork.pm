package ProteinNetwork;
use Gene; use Protein; use KEGG_Term; use GO_Term;
use Moose; use strict;

# Gene Object

=head1 NAME

ProteinNetwork

=head1 DESCRIPTION

A module for representing protein networks based on protein-protein interaction.

=head1 SYNOPSIS

 use ProteinNetwork;
 my $Network = ProteinNetwork->new(Name => $name, Proteins => %ProteinObjects);

=cut

## PROPERTIES

has 'Name' =>(			# Uniprot ID
	is => 'rw',
	isa => 'Str',
	required => 1,
);


has 'Proteins' =>(			# Uniprot ID
	is => 'rw',
	isa => 'HashRef[Protein]',
);


## METHODS


sub MakeNetwork { #This subroutine creates a protein network hash fron a protein hash
my ($ProteinHash_ref, $ProteinsAdded_ref, $NetNumber, $empty)=@_;
my $ProteinsAdded=%{$ProteinsAdded_ref};

my $AddedNumber=1; my $InteractorList;

	while ($AddedNumber>0 and $RemainingNumber>0){ # We keep running &AddToNetwork until no more proteins are added to the network.

		($ProteinsAdded_ref, $AddedNumber,$InteractorList, $empty)=&AddToNetwork(\%ProteinHash,\%ProteinsAdded,$NetNumber,$InteractorList,$empty);
		%ProteinsAdded=%{$ProteinsAdded_ref};
		$RemainingNumber=$RemainingNumber-$AddedNumber;
	}
	return(\%ProteinHash, $RemainingNumber);
}


sub AddToNetwork{ #This subroutine adds proteins from a hash to a network based on their protein-protein interactions.

my ($ProteinHash_ref, $ProteinsAdded_ref, $NetNumber, $InteractorList, $empty)=@_;
my $ProteinsAdded=%{$ProteinsAdded_ref};
my $AddedNumber=0;

foreach my $prot (keys %ProteinHash){ #If the network is empty, we add the first protein

	if ($empty==1){
		if($ProteinsAdded{$prot}==undef){
			$ProteinsAdded{$prot}=$NetNumber;
			$InteractorList='';

			my @Ints=$ProteinHash{$prot}->Interactions->[0];
			foreach my $int (@Ints){

				$InteractorList=$InteractorList.','."$int";			
			}
			$empty=0;
			$AddedNumber=1;
		}
	}else{								# When a network has one or more proteins, we add a new one searching their name or their interactors in the network's InteractorList. This way, we find direct links between two proteins, as well as proteins linked trough a third one.
		$Name=$ProteinHash{$prot}->Synonym;
		
		if ($InteractorList=~/$Name/){
			if($ProteinsAdded{$prot}==undef){ #If the proteins is not included in the hash, we add it.
				$ProteinsAdded{$prot}=$NetNumber;

				my @Ints=$ProteinHash{$prot}->Interactions->[0];
				foreach my $int (@Ints){
					$InteractorList=$InteractorList.','."$int";}
				$AddedNumber=$AddedNumber+1;
			}
		}else{
		my @Ints=$ProteinHash{$prot}->Interactions->[0];

		foreach my $int (@Ints){
			if ($InteractorList=~/$int/){
				if($ProteinsAdded{$prot}==undef){
					$ProteinsAdded{$prot}=$NetNumber;
					foreach my $prots (@Ints){
						$InteractorList=$InteractorList.','."$prots";
					}				
					$AddedNumber=$AddedNumber+1;
				}
			}else{next;}
		}
		}
	
	}

}
	return(\%ProteinsAdded, $AddedNumber, $InteractorList,$empty);
}
1;
