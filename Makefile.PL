# -*- perl -*-

# Thanks to Intrepid and Scott Godin for install troubleshooting

require 5.004;
use strict;
require ExtUtils::MakeMaker;
my %opts = (
    'NAME'         => 'DBD::AnyData',
    'VERSION_FROM' => 'AnyData.pm',
    'PREREQ_PM'    => {
                        'SQL::Statement' => '0',
                        'DBD::File'      => '0',
                        'AnyData'        => '0',
                        'DBI'            => '0',
                      },
    'dist'         => { 'SUFFIX'       => ".gz",
			'DIST_DEFAULT' => 'all tardist',
			'COMPRESS'     => "gzip -9vf",
                      },
     );
if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
    $opts{'AUTHOR'} = 'Jeff Zucker (jeff@vpservices.com)';
}
ExtUtils::MakeMaker::WriteMakefile(%opts);
