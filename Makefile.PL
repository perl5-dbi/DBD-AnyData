# -*- perl -*-

# Thanks to Intrepid and Scott Godin for install troubleshooting

require 5.004;
use strict;
require ExtUtils::MakeMaker;
my %opts = (
    'NAME'         => 'DBD::AnyData',
    'VERSION_FROM' => 'AnyData.pm',
    'PREREQ_PM'    => {
                        'SQL::Statement' => '1',
                        'DBD::File'      => '0.22',
                        'AnyData'        => '0.06',
                        'DBI'            => '1',
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
