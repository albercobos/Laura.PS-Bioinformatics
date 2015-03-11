use LWP::Simple;
use Moose;


my $protein="AT4G27030";
my @Unip=&GOTermsFromLocus($protein);

foreach my $line(@Unip){print "$line \n";}


sub GetProteinID{ # $gene_locus -> $UniprotID
# Gets Uniprot protein ID for a given locus name
	my $gene=$_[0];

	my $web="http://togows.dbcls.jp/search/ebi-uniprot/".$gene;
	my $protID=&get("$web");

	return $protID;
}

sub GetUniprot { # $Uniprot_ID -> @Unirprot_file
# Gets uniprot file for a protein in plain text.
	my $UniprotID=$_[0];

	my $web= 'http://togows.dbcls.jp/entry/ebi-uniprot/'.$UniprotID;
	my @UniprotFile= &get("$web");

	return @UniprotFile;
}

sub GOTermsFromLocus { # $Gene_Locus -> %GO_Terms
# Gets GO Terms for a given locus of A. thaliana.
	my $locus=$_[0]; my @GO_List;

	my $ProteinName=&GetProteinID($locus);
	my $UniprotFile=&GetUniprot($ProteinName);
	
		while ($UniprotFile=~/DR\s{3}GO;\s(GO:\d{7});/g){
			my $GOid=$1;
			push(@GO_List,$GOid);
		}
	return @GO_List;

}








