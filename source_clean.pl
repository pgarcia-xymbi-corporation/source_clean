#!/usr/bin/perl 
use File::Find qw(finddepth);

my @bak;
my @files;
my $string = "\\class:";
my $backup_path_and_file = "$ARGV[0]/backup";
my $backup_path = "$ARGV[0]/backup";
# .../athena/backup
my $output_path = "$ARGV[0]";
my $tmp_dir = "$ARGV[0]/tmp";
my $bak_dir = "$ARGV[0]/backup";
my $stem = $ARGV[0];

# FINDS ALL FILES

print "Looking in the specified directory\n";

finddepth(sub {
    return if(    $_ eq '.'
               || $_ eq '..'
             );
    if (    (    ( $File::Find::name !~ /\.svn\// )
              && ( $File::Find::name !~ /tests\// )
            )
         && (    ( $File::Find::name =~ /.+\.h$/   )
              || ( $File::Find::name =~ /.+\.hpp$/ )
              || ( $File::Find::name =~ /.+\.tcc$/ )
              || ( $File::Find::name =~ /.+\.cpp$/ )
            )
       )
    {
        push @files, $File::Find::name;
    }
},  $ARGV[ 0 ] );


my @mod_files;
foreach $file ( @files ) {

    if ( $file =~ /.*\/backup\/.?/ ) { next; }

    my $searchstring = quotemeta $stem;

    $file =~ /^$searchstring\/(.*)/;
    
    #print "$1\n";

    push @mod_files, $1;
}


# MAKES TEMP AND BACKUP DIRECTORIES

#system( "mkdir $tmp_dir" );
print "Creating backup directory\n";

system( "mkdir $bak_dir"  );

# example copy
print "Backing up files...\n";

foreach $file ( @mod_files ) {

    $file =~ /(.*\/).*$/;
    my $subdir = $1;
    if ( $subdir ) {
        system( "mkdir -p $stem/backup/$subdir" );
    }

    system( "mv $stem/$file $bak_dir/$file" );
}

print "Done.\n";

# TODO: Print some progress and number of changes etc. ## COMES LAST

# TODO: Must use mkdir -f in Linux

# CLEANS CODE

print "Opening mod files...\n";

foreach $file ( @mod_files ) {

    $file =~ /.*\/(.*)$/;
    #my $subdir = $1;
    #print "mkdir -p $tmp_dir/$subdir\n";
    #if ( $subdir ) {
        #system( "mkdir -p $tmp_dir/$subdir" );
    #}

    #print ">/\n";
    #open( OUT, ">/" );

    open( FILE, "$bak_dir/$file"  );
    @lines = <FILE>;
    close(  FILE  );

    #print "Input: $bak_dir/$file --- Output file: $tmp_dir/$file\n";
    open( OUT, ">$stem/$file" );

    foreach $line ( @lines ) {

        if ( $line =~ /\s\\class:*\s/    ) { next; }
        if ( $line =~ /\s\\fn:*\s/       ) { next; }
        if ( $line =~ /\s\\Version:*\s/  ) { next; }
        if ( $line =~ /\s\\Compiler*\s/  ) { next; }

        print OUT $line;
    }    

    close( OUT );
}

print "Removed all class tags\n";
print "Removed all fn tags\n";

#print "Removing all Revision header lines\n";

#system ( "grep -l 'Revision' $stem -R | xargs -I'{}' sed -i '/Revision/d'" );

#print "Removing all Version header lines\n";

#system ( "grep -l 'Version' $stem -R | xargs -I'{}' sed -i '/Version/d'" );

#print "Removing all Compiler header lines\n";

#system ( "grep -l 'Compiler' $stem -R | xargs -I'{}' sed -i '/Compiler/d'" );

print "Removing all colons...\n";

system ( "grep -lr  -e 'brief:' $stem | xargs sed -i 's/brief:/brief/g'" );


print "All files processed, we're finished here.\n";

exit;