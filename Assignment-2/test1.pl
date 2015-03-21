use JSON; use LWP::Simple; use GO_Term; use KEGG_Term; use Gene; use Protein; 
use strict;


my (%ProteinHash,%GeneHash);

	open (FILEHANDLE, 'GeneList2');
	my @locus = <FILEHANDLE>;
	close FILEHANDLE;

foreach my $gene(@locus){
	my $GeneObject=Gene -> new (
		ID=>"$gene"	
	);
	$GeneHash{$gene}=$GeneObject;
	}
	

$ProteinHash=&Gene::CreateProtein(\%GeneHash);


foreach my $key (keys %$ProteinHash){
	my $NetworkNumber=0;
	@Interactor1=['Q8LC55','PSBQ2'];
	@Interactor2=['Q93VG3', 'FAD4'];
	if ($NetworkNumber<5){
		$ProteinHash->{$key}->Interactions(@Interactor1);
		$NetworkNumber=$NetworkNumber++;
	}elsif ($NetworkNumber>=5){
		$ProteinHash->{$key}->Interactions(@Interactor2);
	}
}

my @ProteinsAdded; my $AddedNumber=1;
my @Network_Interactors; my $empty=1;
my $NetworkNumber=0;
my $TotalProteins=scalar(keys %$ProteinHash);
my $RemainingProteins=$TotalProteins;

while ($RemainingProteins>0){

($ProteinsAdded[$NetworkNumber],$AddedNumber, $Network_Interactors[$NetworkNumber])=&MakeNetwork(%$ProteinHash,$ProteinsAdded[$NetworkNumber], $AddedNumber, $NetworkInteractors[$NetworkNumber], $empty, $NetworkNumber);

}


sub MakeNetwork{
my $ProteinHash=$_[0]; my $ProteinsAdded=$_[1]; my $AddedNumber=$_[2];
my $Network_Interactors=$_[3]; my $empty=$_[4]; my $NetworkNumber=$_[5];

while ($AddedNumber>0){
	($ProteinsAdded[$NetworkNumber],$AddedNumber, $Network_Interactors[$NetworkNumber])=&AddToNetwork(%$ProteinHash,$ProteinsAdded[$NetworkNumber], $AddedNumber, $NetworkInteractors[$NetworkNumber], $empty, $NetworkNumber);
}
return($ProteinsAdded, $AddedNumber, $Network_Interactors);
}

sub AddToNetwork{
my $ProteinHash=$_[0]; my $ProteinsAdded=$_[1]; my $AddedNumber=$_[2];
my $Network_Interactors=$_[3]; my $empty=$_[4]; my $NetworkNumber=$_[5];


	foreach my $key (keys %$ProteinHash){
		if ($empty==1){

			$ProteinsAdded[$NetworkNumber]=$ProteinHash->{$key}->{'Name'};
			$Network_Interactors[$NetworkNumber]=join ($ProteinHash->{$key}->{'Interactors'},',');
			$empty=0;
			$AddedNumber=1;
		}elsif ($empty==0){
			
				if ($NetworkInteractors[$NetworkNumber]=~/$ProteinHash->{$key}->{'Synonym'}/){
					$ProteinsAdded[$NetworkNumber]=$ProteinHash->{$key}->{'Name'};
					$Network_Interactors[$NetworkNumber]=join ($ProteinHash->{$key}->{'Interactors'},',');
					$AddedNumber++;
					next;
				}
		}
	}
return($ProteinsAdded, $AddedNumber, $Network_Interactors);
}

