



use Moose;

use SeedStock;
#use strict;



#Scrip to update seedstock


print"Type the stock file path: \n";
my $filename=<STDIN>;
chomp $filename;
print"How many seeds do you want to plant? \n";
my $SeedAmount=<STDIN>;
chomp $SeedAmount;

print"Do you want to rewrite the stock file? [Y/N]";
my $rw=<STDIN>;
chomp $rw;
my $NewFile;
if ($rw=~/[Y|y]/){$NewFile=$filename;}
elsif($rw=~/[N|n]/){
	print"Choose a name for the new stock file: \n";
	$NewFile=<STDIN>;
	chomp $NewFile;
	}




my $stock_data = &load_stock($filename);


&plant_seeds($stock_data,$SeedAmount,$NewFile);






##########################



sub Ask_Date{ #Asks the system for current date.

my $date; my $datetime;

$datetime = `date`;

if ($datetime=~/\w{3}.(\w{3}).(\d{2}).*(\d{4})/){

	if($1 eq "ene"){$date="$2/01/$3";}

	elsif($1 eq "feb"){$date="$2/02/$3";}

	elsif($1 eq "mar"){$date="$2/03/$3";}

	elsif($1 eq "abr"){$date="$2/04/$3";}

	elsif($1 eq "may"){$date="$2/05/$3";}

	elsif($1 eq "jun"){$date="$2/06/$3";}

	elsif($1 eq "jul"){$date="$2/07/$3";}

	elsif($1 eq "ago"){$date="$2/08/$3";}

	elsif($1 eq "sep"){$date="$2/09/$3";}

	elsif($1 eq "oct"){$date="$2/10/$3";}

	elsif($1 eq "nov"){$date="$2/11/$3";}

	elsif($1 eq "dec"){$date="$2/12/$3";}

}

return $date;

}


sub load_stock{ #Loads information from the seed stock data base.
	my $stockfile=$_[0];


	my @file=&get_data($stockfile);


	my %SeedHash; #Contains the seeds IDs to create seedstock objects.



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
	
		}else{print$SeedID.'\'s mutant gene need to have a standard format: [a|A][t|T]\d[G|g]\d{5}';}
	}	
	return \%SeedHash;
}

sub plant_seeds{

	my ($StockData, $Amount, $StockFile)=@_;
	my $NewStock; my $check;
	
	#print(${$StockData}{'A334'}->Storage);
	
	$check=&check_stock($StockData,$Amount); #First, checking we have enough seeds.
	if ($check==1){return;}						
	else{									# Rewriting stock database
		my $Header='Seed_Stock	Mutant_Gene_ID	Last_Planted	Storage	Grams_Remaining';
		my $Remain;
		open (OUTFILE, ">$StockFile"); 
		print OUTFILE "$Header \n";
		close FILEHANDLE;
	
		foreach my $Seed (keys %{$StockData}){
		$NewStock=${$StockData}{$Seed};
		$Remain=$NewStock->GramsRemaining-$Amount;
		$NewStock->GramsRemaining($Remain);
		&write_stock($NewStock,$StockFile);
		}
	}
}


sub check_stock{ #Tests if there are seeds enough to plant
	my ($StockData, $Amount)=@_;
	my $ID;
	
	foreach my $Seed (keys %{$StockData}){ 
		if (${$StockData}{$Seed}->GramsRemaining<$Amount){
			$ID=${$StockData}{$Seed}->SeedID;
			print"There aren\'t enough $ID seeds in the stock.";
			return 1;
		}elsif(${$StockData}{$Seed}->GramsRemaining==$Amount){
			$ID=${$StockData}{$Seed}->SeedID;
			print"You've planted the last $ID seeds!";
			return 0;
		}
	}
}

sub write_stock{
	my ($NewStock,$FileName) =@_;
	my $line; my $Date;
	$Date = &Ask_Date;
	$NewStock->LastPlanted($Date);
	$line=$NewStock->SeedID."\t".$NewStock->MutantGene."\t".$NewStock->LastPlanted."\t".$NewStock->Storage."\t".$NewStock->GramsRemaining;

	open (OUTFILE, ">>$FileName"); 
	print OUTFILE "$line \n";
	close FILEHANDLE;
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

