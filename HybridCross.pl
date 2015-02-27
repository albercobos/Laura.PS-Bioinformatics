#! perl -w
use Moose;
use Gene;
use HybridCross;
use SeedStock;

print"Type your Hybrid Cross, Seed Stock and Gene databases; \n";


my$Cross_File=<STDIN>;
my$Stock_File=<STDIN>;
my$Gene_File=<STDIN>;
chomp($Cross_File,$Stock_File,$Gene_File);


my $Gene_Data=&load_gene_data($Gene_File);
my $Stock_Data = &load_stock($Stock_File);
my $Cross_Data=&load_cross_data($Cross_File);

my $chi=0;
my $Filename = substr($Gene_File,0,-4).' with Linkage.tsv';
&linkage_analysis($Cross_Data,$Stock_Data,$Gene_Data);



#############################
sub load_stock{ #Loads information from the seed stock data base.
	my $stockfile=$_[0];


	my @file=&get_data($stockfile);


	my %SeedHash; #Contains the seeds IDs to create seedstock objects.
	my $gene;



	for (my $i=1;$i<scalar@file;$i++){

		my ($SeedID,$MutantGene,$LastPlanted,$Storage,$GramsRemaining)= split("\t", $file[$i]);

		chomp ($SeedID,$MutantGene,$LastPlanted,$Storage,$GramsRemaining);
		
		if ($MutantGene=~/[a|A][t|T]\d[G|g]\d{5}/){
		#Checking gene ID has the right format.
		
			my $SeedObject = SeedStock -> new (

				SeedID=>"$SeedID",

				MutantGene=>"$MutantGene",

				LastPlanted=>"$LastPlanted",

				Storage=>"$Storage",

				GramsRemaining=>$GramsRemaining,

				);
		
			$SeedHash{$SeedID} = $SeedObject;
	
		}else{print$SeedID.'\'s mutant gene needs to have a standard format: [a|A][t|T]\d[G|g]\d{5}';}
	}	
	return \%SeedHash;
}

sub load_cross_data{ #Loads information from the hybrid cross data base.
	my $crossfile=$_[0];


	my @file=&get_data($crossfile);


	my %CrossHash; #Contains the seeds IDs to create seedstock objects.



	for (my $i=1;$i<scalar@file;$i++){

		my ($Parent1,$Parent2,$F2_Wild,$F2_P1,$F2_P2,$F2_P1P2)= split("\t", $file[$i]);

		chomp ($Parent1,$Parent2,$F2_Wild,$F2_P1,$F2_P2,$F2_P1P2);
		
		my $CrossObject = HybridCross -> new (

				Parent1=>"$Parent1",
				Parent2=>"$Parent2",
				F2_Wild=>"$F2_Wild",

				F2_P1=>"$F2_P1",

				F2_P2=>"$F2_P2",

				F2_P1P2=>"$F2_P1P2",

				);
		
			$CrossHash{$Parent1.$Parent2} = $CrossObject;
	

	}	
	return \%CrossHash;
}

sub load_gene_data{ #Loads information from the gene data base.
	my $genefile=$_[0];


	my @file=&get_data($genefile);


	my %GeneHash; #Contains the seeds IDs to create seedstock objects.



	for (my $i=1;$i<scalar@file;$i++){

		my ($ID,$name,$pheno)= split("\t", $file[$i]);

		chomp ($ID,$name,$pheno);
		
		if ($ID=~/[a|A][t|T]\d[G|g]\d{5}/){
		#Checking gene ID has the right format.
			my $GeneObject = Gene -> new (

					ID=>"$ID",
					Name=>"$name",
					Phenotype=>"$pheno",

					);
		
			$GeneHash{$ID} = $GeneObject;
		}else{print$$name.' gene ID needs to have a standard format: [a|A][t|T]\d[G|g]\d{5}';}	

	}	
	return \%GeneHash;
}

sub linkage_analysis{

	my ($Cross_Data,$Stock_Data,$Gene_Data)=@_;
	my $chi; my $Cross;
	foreach $Cross (keys %{$Cross_Data}){
		$chi=&calculate_chi($Cross);

		my $Parent1; my $Parent2;my $linked1; my $linked2;	
		
		if($chi>7.815){  # Both genes are considered linked (error=5%) when chi value is higher than 7.81. 
	
			$Parent1 =${$Cross_Data}{$Cross}->Parent1; 
			$Parent2 =${$Cross_Data}{$Cross}->Parent2;
			$linked1=${$Stock_Data}{$Parent1}->MutantGene; 
			$linked2=${$Stock_Data}{$Parent2}->MutantGene;
				
			print "Linkage found between $linked1 and $linked2\n";
			&rewrite_gene_data($Gene_Data,$linked1, $linked2, $Filename);
		
		}else{print "No linkage found between $linked1 and $linked2\n";}		
	}
}


sub calculate_chi{
	my $Cross=$_[0];
	my $Wild; my $Mutant1; my $Mutant2; my $Mutant12; my $total;
	
	$total=${$Cross_Data}{$Cross}->F2_Wild+${$Cross_Data}{$Cross}->F2_P1+${$Cross_Data}{$Cross}->F2_P2+${$Cross_Data}{$Cross}->F2_P1P2;
		
	#Observed
	my @observed=[${$Cross_Data}{$Cross}->F2_Wild,${$Cross_Data}{$Cross}->F2_P1,${$Cross_Data}{$Cross}->F2_P2,${$Cross_Data}{$Cross}->F2_P1P2];
	
	#Expected F2: 	 #We expect this distribution for F2 if both genes are independant
	$Wild=(${$Cross_Data}{$Cross}->F2_Wild)*9/16;
	$Mutant1=(${$Cross_Data}{$Cross}->F2_P1)*3/16;
	$Mutant2=(${$Cross_Data}{$Cross}->F2_P2)*3/16;
	$Mutant12=(${$Cross_Data}{$Cross}->F2_P1P2)/16;

	my @expected =[$Wild, $Mutant1, $Mutant2, $Mutant12];
	
	for (my $i=0;$i<scalar@expected;$i++){

		$chi=$chi+(($observed[$i]-$expected[$i])**2)/$expected[$i];
	}
	return $chi;		
}

sub rewrite_gene_data{
	my($Gene_Data,$linked1,$linked2,$GeneFile)=@_; my $Gene;
		my $Header='Gene_ID	Gene_name	mutant_phenotype	Linkage';
		
		if (defined ${$Gene_Data}{$linked1}->Linkage){
		my$linkage=${$Gene_Data}{$linked1}->Linkage.",".$linked2;
		${$Gene_Data}{$linked1}->Linkage($linkage);
		}else{${$Gene_Data}{$linked1}->Linkage($linked2);}
		
		if (defined ${$Gene_Data}{$linked2}->Linkage){
		my$linkage=${$Gene_Data}{$linked2}->Linkage.",".$linked1;
		${$Gene_Data}{$linked2}->Linkage($linkage);
		}else{${$Gene_Data}{$linked2}->Linkage($linked1);}
		
		open (OUTFILE, ">$GeneFile"); 
		print OUTFILE "$Header \n";
		close FILEHANDLE;
		foreach $Gene (keys %{$Gene_Data}){
		
		
			my $line=${$Gene_Data}{$Gene}->ID."\t".${$Gene_Data}{$Gene}->Name."\t".${$Gene_Data}{$Gene}->Phenotype."\t";
			if (defined ${$Gene_Data}{$Gene}->Linkage){$line=$line.${$Gene_Data}{$Gene}->Linkage;}
			
			open (OUTFILE, ">>$GeneFile"); 
			print OUTFILE "$line \n";
			close FILEHANDLE;	
		
		}

}


sub open_file{ #(ruta del archivo)



	my $ruta=$_[0]; my @file;

	open(FILEHANDLE, "<$ruta") or die "File can't be opened.\n";

	@file=<FILEHANDLE>;

	close FILEHANDLE;

	return @file;

}



sub get_data { #($ruta del archivo)



	my $ruta=$_[0]; my @file;

	@file=&open_file($ruta);

	return @file;

}
