#!/usr/bin/perl -w

$destdir = "community-diff";
$basedir = "~/arch-abs";
$repo = "community";
$arch1 = "i686";
$arch2 = "x86_64";

#####################################

!system("mkdir -p $destdir") || die "can not create destdir";

$template = "[a-z0-9+\\-\\._]+";

%PKGS=();

#
# Search 1st arch
#

print "Searching $arch1/$repo...\n";

open FIND, "find $basedir/$arch1/$repo -name PKGBUILD -exec dirname {} \\; |" || die "can not find files";

while(<FIND>)
{
    chomp;
    if(/\/($template)\/($template)$/i)
    {
        $group = $1;
	$pkg = $2;
	$PKGS{$group."/".$pkg} = 1;
    }
    else
    {
	die "bad find result";
    }
}

close FIND;

#
# Search 2nd arch
#

print "Searching $arch2/$repo...\n";

open FIND, "find $basedir/$arch2/$repo -name PKGBUILD -exec dirname {} \\; |" || die "can not find files";

while(<FIND>)
{
    chomp;
    if(/\/($template)\/($template)$/i)
    {
        $group = $1;
	$pkg = $2;
	$PKGS{$group."/".$pkg} = 1;
    }
    else
    {
	die "bad find result";
    }
}

close FIND;

#
# Diff
#

print "Comparing...\n";

open IDXFH, ">$destdir/index.html" || die "Can not open index.html";

$title = "$repo diff ($arch1 vs $arch2)".`date +%Y.%m.%d.%H.%m`;

print IDXFH "<HTML><HEAD><TITLE>$title</TITLE></HEAD><BODY><H1>$title</H1>\n";
print IDXFH "<TABLE width='100%' border=1px>\n";

foreach $i (sort keys %PKGS)
{
    if($i =~ /^(.+)\/(.+)$/)
    {
        $group = $1;
	$pkg = $2;
    }
    else
    {
        die("bad param");
    }

    $p1 = `./pkg.sh $basedir/$arch1/$repo/$group/$pkg/PKGBUILD`;
    $p2 = `./pkg.sh $basedir/$arch2/$repo/$group/$pkg/PKGBUILD`;

    $p1 = "&nbsp;" if($p1 eq "");
    $p2 = "&nbsp;" if($p2 eq "");

    if($p1 ne $p2)
    {
        $diff = `diff2html -N $basedir/$arch1/$repo/$group/$pkg/PKGBUILD $basedir/$arch2/$repo/$group/$pkg/PKGBUILD`;

	print "DIFF: $repo-$group-$pkg\n";
	if($p1 lt $p2)
	{
    	    print IDXFH "<TR><TD>$group<TD><A HREF=\"$repo-$group-$pkg.html\">$pkg</A><TD bgcolor=red>$p1<TD>$p2</TR>\n";
	}
	else
	{
    	    print IDXFH "<TR><TD>$group<TD><A HREF=\"$repo-$group-$pkg.html\">$pkg</A><TD>$p1<TD bgcolor=red>$p2</TR>\n";
	}
	open FH, ">$destdir/$repo-$group-$pkg.html" || die "can not write diff";
    	print FH $diff;
    	close FH;
    }
}

print IDXFH "</TABLE></BODY></HTML>\n";

close IDXFH;
