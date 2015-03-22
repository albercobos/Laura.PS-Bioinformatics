use JSON; use LWP::Simple; use GO_Term; use KEGG_Term; use Gene; use Protein; use ProteinNetwork;
#use strict;


my (%ProteinHash,%GeneHash);

my $GeneFile=$ARGV[0]; # Contains a list of gene locus

my $NetworkFile=$ARGV[1]; # The network information will be stored in this file.

if ($GeneFile==undef or $NetworkFile==undef){print "You need a gene locus and a saving filenames. Example: perl ProteinNetworks.pl GeneFile.txt NetworkFile.txt\n"}

## LOADING PROTEINS FROM GENE LOCUS LIST

	open (FILEHANDLE, "$GeneFile");
	my @locus = <FILEHANDLE>;
	close FILEHANDLE;

foreach my $gene(@locus){ 
	my $GeneObject=Gene -> new (
		ID=>"$gene");
	$GeneHash{$gene}=$GeneObject;
	}
	
$ProteinHash=&Gene::CreateProtein(\%GeneHash);

## MAKING PROTEIN NETWORKS

my $NetNumber=1;
my $empty=1;
my %ProteinsAdded; my $InteractorList;
my $ProteinsAdded_ref;

my $TotalProteins=scalar(keys%ProteinHash);
my $RemainingNumber=$TotalProteins;

while ($RemainingNumber>0){ 

# First, we assign a network to every protein in the hash. 

($ProteinsAdded_ref, $RemainingNumber)=&ProteinNetwork::MakeNetwork(\%ProteinHash,\%ProteinsAdded,$NetNumber,$empty,$RemainingNumber);
%ProteinsAdded=%{$ProteinsAdded_ref};
$NetNumber=$NetNumber+1;
$empty=1;
}

# Then, we make a hash of protein objects for every network and create the network objects.
my %Network_List;
for (my $i=1;$i<$NetNumber;$i++){
	my $NetworkHash_ref=&ProteinNetwork::HashFromNetwork(\%ProteinHash,\%ProteinsAdded, $i);
	my $NetworkObject = ProteinNetwork->new( Number=>"$i");
	$NetworkObject->Proteins($NetworkHash_ref);
	
	$Network_List{$i}=$NetworkObject;
}

#This script prints your networks in a file

open (OUTFILE, '>$NetworkFile'); 

foreach my $net(keys %Network_List){
print OUTFILE "NETWORK NUMBER: $net \n";
foreach my $prot(keys $Network_List{$net}->Proteins){

print OUTFILE $prot,"\t";
}
print OUTFILE "\n\n";
}







