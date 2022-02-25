#!/usr/bin/perl -w
# dbinv.pl
# 8/2/05

use DBI;
require "subparseform.lib";
require "env.lib";
require "body_html.lib";

&Parse_Form;

$in_alias_id = $formdata{'alias_id'};

my $local_url = "http://10.113.9.20/cgi-bin/";

my $dbh = DBI->connect( '', '', '',
                        { RaiseError => 1, AutoCommit => 0 } );

print_body_html('LRN DB Servers');

print<<HTML;
<FORM name="test" method="POST" action="dbinv.pl">
HTML

### machine drop down

print<<HTML;
<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>
<TR>
<TD VALIGN="TOP" ALIGN="CENTER" HEIGHT="25">
<P>
<B>Environment</B>
<SELECT NAME="alias_id">
HTML

my $sqla = qq   {
                        SELECT
                                id,
                                alias
                        FROM dbafix.dbinv_db_alias
                        ORDER by alias
                };

my $sth1 = $dbh->prepare( $sqla );
$sth1->execute();

my $table_array1 = $sth1->fetchall_arrayref();

my $rownum_user=0;

foreach my $row1 (@$table_array1) {
        my (
                $alias_id,
                $alias
        ) = @$row1;

        $rownum_user++;

        print "<OPTION ";
        if ($alias_id eq $in_alias_id) {
           print "SELECTED ";
       }
        print "VALUE=";
        print '"';
        print "$alias_id";
        print '">';
        print"$alias";
        print"\n";
}

print<<HTML;
</SELECT>
</TD>;

<TD>
<input type="submit" name="submit" value ="Run">
</TD>
</TR>
</TABLE>
HTML



### machine detail

my $sql1 = qq   {       SELECT
                                NVL(m.hostname,'-'),
                                NVL(m.ip,'-'),
                                NVL(m.os,'-'),
                                NVL(m.location,'-'),
                                NVL(m.cpu,0),
                                NVL(m.ram_gb,0),
                                NVL(m.model,'-'),
                                NVL(m.note,'-'),
                                NVL(m.status,'-')
                        FROM    dbafix.dbinv_machine m,
                                dbafix.dbinv_db_alias a
                        WHERE m.hostname = a.hostname
                        AND a.id = ?
                        ORDER BY m.hostname
                };

my $sth2 = $dbh->prepare( $sql1 );
$sth2->execute($in_alias_id);

my $table_array2 = $sth2->fetchall_arrayref();


print<<HTML;
<P>
<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>
<CAPTION ALIGN=top>Machine Info</CAPTION>
<COLGROUP SPAN=2>
<TR>
<TH>Host Name
<TH>IP Address
<TH>OS
<TH>Location
<TH>CPUs
<TH>RAM (gb)
<TH>Model
<TH>Status
<TH>Notes
</TR>

<TBODY>
HTML

my $rownum2=0;

foreach my $row (@$table_array2) {

        my (
                $hostname,
                $ip,
                $os,
                $location,
                $cpu,
                $ram_gb,
                $model,
                $note,
                $status
        ) = @$row;

        if ( $hostname ne "" ) { $old_hostname = $hostname };

        $rownum2++;

        print "<TR><TD>";
        print "$hostname";
        print "</TD><TD>";
        print "$ip";
        print "</TD><TD>";
        print "$os";
        print "</TD><TD>";
        print "$location";
        print "</TD><TD>";
        print "$cpu";
        print "</TD><TD>";
        print "$ram_gb";
        print "</TD><TD>";
        print "$model";
        print "</TD><TD>";
        print "$status";
        print "</TD><TD>";
        print "$note";
        print "</TD></TR>\n";

}

print "<TBODY></TABLE>";


### instance detail

my $sql2 = qq    {       SELECT
                                i.id,
                                NVL(i.instance_name,'-'),
                                NVL(i.type,'-'),
                                NVL(i.datafile_path,'-'),
                                NVL(i.oracle_home,'-'),
                                NVL(i.alert_log_dir,'-'),
                                NVL(i.status,'-'),
                                NVL(i.port,0),
                                NVL(i.service_name,'-'),
                                NVL(i.note,'-')
                        FROM    dbafix.dbinv_instance i,
                                dbafix.dbinv_db_alias a
                        WHERE a.id = ?
                        AND a.hostname = i.hostname
                        ORDER BY instance_name
                };

my $sth3 = $dbh->prepare( $sql2 );
$sth3->execute($in_alias_id);

my $table_array3 = $sth3->fetchall_arrayref();


print<<HTML;
<P>
<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>
<CAPTION ALIGN=top>DB Instances on $old_hostname</CAPTION>
<COLGROUP SPAN=2>
<TR>
<TH>Instance
<TH>Type
<TH>Datafile Path
<TH>Oracle Home,
<TH>Alert Log
<TH>Status
<TH>Port
<TH>Service Name
<TH>Refreshes
<TH>Note
</TR>

<TBODY>
HTML

my $rownum3=0;

foreach my $row (@$table_array3) {

        my (
               $id,
               $instance_name,
               $type,
               $datafile_path,
               $oracle_home,
               $alert_log_dir,
               $status,
               $port,
               $service_name,
               $note
        ) = @$row;

        $rownum3++;

        print "<TR><TD>";
        print $instance_name;
        print "</TD><TD>";
        print $type;
        print "</TD><TD>";
        print "$datafile_path";
        print "</TD><TD>";
        print "$oracle_home";
        print "</TD><TD>";
        print "$alert_log_dir";
        print "</TD><TD>";
        print "$status";
        print "</TD><TD>";
        print "$port";
        print "</TD><TD>";
        print "$service_name";
        print "</TD><TD>";
        print "<A HREF=";
        print '"';
        print $local_url;
        print "dbinv_refresh_hist.pl";
        print "?instance_id=";
        print "$id";
        print '"';
        print "TARGET=$id>";
        print "history";
        print  "</A>";
        print "</TD><TD>";
        print "$note";
        print "</TD></TR>\n";

}

print "</TABLE>";


### Table links

print "<P>";
print '<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>';
print "\n";


print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_machines.pl";
print '"';
print " TARGET=machine_list>";
print "Machine List";
print  "</A>";
print "</TD></TR>\n";

print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_instances.pl";
print '"';
print " TARGET=instance_list>";
print "Instance List";
print  "</A>";
print "</TD></TR>\n";

print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_instance_hist.pl";
print '"';
print " TARGET=refresh_hist_list>";
print "Refresh History List";
print  "</A>";
print "</TD></TR>\n";

print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_publish_hist.pl";
print '"';
print " TARGET=refresh_hist_list>";
print "Publish History List";
print  "</A>";
print "</TD></TR>\n";


print "<TBODY></TABLE>";

$dbh->disconnect();

print "</BODY>";
[root@prdoraco6dba01 cgi-bin]# cat dbinv.pl
#!/usr/bin/perl -w
# dbinv.pl
# 8/2/05

use DBI;
require "subparseform.lib";
require "env.lib";
require "body_html.lib";

&Parse_Form;

$in_alias_id = $formdata{'alias_id'};

my $local_url = "http://10.113.9.20/cgi-bin/";

my $dbh = DBI->connect( 'dbi:Oracle:lcecdb', 'dba_website', 'lcecro9',
                        { RaiseError => 1, AutoCommit => 0 } );

print_body_html('LRN DB Servers');

print<<HTML;
<FORM name="test" method="POST" action="dbinv.pl">
HTML

### machine drop down

print<<HTML;
<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>
<TR>
<TD VALIGN="TOP" ALIGN="CENTER" HEIGHT="25">
<P>
<B>Environment</B>
<SELECT NAME="alias_id">
HTML

my $sqla = qq   {
                        SELECT
                                id,
                                alias
                        FROM dbafix.dbinv_db_alias
                        ORDER by alias
                };

my $sth1 = $dbh->prepare( $sqla );
$sth1->execute();

my $table_array1 = $sth1->fetchall_arrayref();

my $rownum_user=0;

foreach my $row1 (@$table_array1) {
        my (
                $alias_id,
                $alias
        ) = @$row1;

        $rownum_user++;

        print "<OPTION ";
        if ($alias_id eq $in_alias_id) {
           print "SELECTED ";
       }
        print "VALUE=";
        print '"';
        print "$alias_id";
        print '">';
        print"$alias";
        print"\n";
}

print<<HTML;
</SELECT>
</TD>;

<TD>
<input type="submit" name="submit" value ="Run">
</TD>
</TR>
</TABLE>
HTML



### machine detail

my $sql1 = qq   {       SELECT
                                NVL(m.hostname,'-'),
                                NVL(m.ip,'-'),
                                NVL(m.os,'-'),
                                NVL(m.location,'-'),
                                NVL(m.cpu,0),
                                NVL(m.ram_gb,0),
                                NVL(m.model,'-'),
                                NVL(m.note,'-'),
                                NVL(m.status,'-')
                        FROM    dbafix.dbinv_machine m,
                                dbafix.dbinv_db_alias a
                        WHERE m.hostname = a.hostname
                        AND a.id = ?
                        ORDER BY m.hostname
                };

my $sth2 = $dbh->prepare( $sql1 );
$sth2->execute($in_alias_id);

my $table_array2 = $sth2->fetchall_arrayref();


print<<HTML;
<P>
<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>
<CAPTION ALIGN=top>Machine Info</CAPTION>
<COLGROUP SPAN=2>
<TR>
<TH>Host Name
<TH>IP Address
<TH>OS
<TH>Location
<TH>CPUs
<TH>RAM (gb)
<TH>Model
<TH>Status
<TH>Notes
</TR>

<TBODY>
HTML

my $rownum2=0;

foreach my $row (@$table_array2) {

        my (
                $hostname,
                $ip,
                $os,
                $location,
                $cpu,
                $ram_gb,
                $model,
                $note,
                $status
        ) = @$row;

        if ( $hostname ne "" ) { $old_hostname = $hostname };

        $rownum2++;

        print "<TR><TD>";
        print "$hostname";
        print "</TD><TD>";
        print "$ip";
        print "</TD><TD>";
        print "$os";
        print "</TD><TD>";
        print "$location";
        print "</TD><TD>";
        print "$cpu";
        print "</TD><TD>";
        print "$ram_gb";
        print "</TD><TD>";
        print "$model";
        print "</TD><TD>";
        print "$status";
        print "</TD><TD>";
        print "$note";
        print "</TD></TR>\n";

}

print "<TBODY></TABLE>";


### instance detail

my $sql2 = qq    {       SELECT
                                i.id,
                                NVL(i.instance_name,'-'),
                                NVL(i.type,'-'),
                                NVL(i.datafile_path,'-'),
                                NVL(i.oracle_home,'-'),
                                NVL(i.alert_log_dir,'-'),
                                NVL(i.status,'-'),
                                NVL(i.port,0),
                                NVL(i.service_name,'-'),
                                NVL(i.note,'-')
                        FROM    dbafix.dbinv_instance i,
                                dbafix.dbinv_db_alias a
                        WHERE a.id = ?
                        AND a.hostname = i.hostname
                        ORDER BY instance_name
                };

my $sth3 = $dbh->prepare( $sql2 );
$sth3->execute($in_alias_id);

my $table_array3 = $sth3->fetchall_arrayref();


print<<HTML;
<P>
<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>
<CAPTION ALIGN=top>DB Instances on $old_hostname</CAPTION>
<COLGROUP SPAN=2>
<TR>
<TH>Instance
<TH>Type
<TH>Datafile Path
<TH>Oracle Home,
<TH>Alert Log
<TH>Status
<TH>Port
<TH>Service Name
<TH>Refreshes
<TH>Note
</TR>

<TBODY>
HTML

my $rownum3=0;

foreach my $row (@$table_array3) {

        my (
               $id,
               $instance_name,
               $type,
               $datafile_path,
               $oracle_home,
               $alert_log_dir,
               $status,
               $port,
               $service_name,
               $note
        ) = @$row;

        $rownum3++;

        print "<TR><TD>";
        print $instance_name;
        print "</TD><TD>";
        print $type;
        print "</TD><TD>";
        print "$datafile_path";
        print "</TD><TD>";
        print "$oracle_home";
        print "</TD><TD>";
        print "$alert_log_dir";
        print "</TD><TD>";
        print "$status";
        print "</TD><TD>";
        print "$port";
        print "</TD><TD>";
        print "$service_name";
        print "</TD><TD>";
        print "<A HREF=";
        print '"';
        print $local_url;
        print "dbinv_refresh_hist.pl";
        print "?instance_id=";
        print "$id";
        print '"';
        print "TARGET=$id>";
        print "history";
        print  "</A>";
        print "</TD><TD>";
        print "$note";
        print "</TD></TR>\n";

}

print "</TABLE>";


### Table links

print "<P>";
print '<TABLE ALIGN=CENTER BGCOLOR="#F0F0F0" BORDER>';
print "\n";


print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_machines.pl";
print '"';
print " TARGET=machine_list>";
print "Machine List";
print  "</A>";
print "</TD></TR>\n";

print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_instances.pl";
print '"';
print " TARGET=instance_list>";
print "Instance List";
print  "</A>";
print "</TD></TR>\n";

print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_instance_hist.pl";
print '"';
print " TARGET=refresh_hist_list>";
print "Refresh History List";
print  "</A>";
print "</TD></TR>\n";

print "<TR><TD>";
print "<A HREF=";
print '"';
print $local_url;
print "dbinv_list_publish_hist.pl";
print '"';
print " TARGET=refresh_hist_list>";
print "Publish History List";
print  "</A>";
print "</TD></TR>\n";


print "<TBODY></TABLE>";

$dbh->disconnect();

print "</BODY>";

