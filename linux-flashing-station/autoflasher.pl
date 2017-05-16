#!/usr/bin/perl
use warnings;
use strict;
use IPC::Run;
use Term::ReadKey;

my $firmware_dir = "firmware/";

my $firmware = { atmega32u4 => $firmware_dir. "atmega.hex",
		 attiny88   => $firmware_dir. "attiny.hex"
	};

#http://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny88&LOW=4E&HIGH=DD&EXTENDED=FE&LOCKBIT=FF
my $fuses = { attiny88 => "-e -Ulfuse:w:0xeE:m -Uhfuse:w:0xDD:m -Uefuse:w:0xFE:m",
	      atmega32u4 => "-e -Ulock:w:0xFF:m -Uefuse:w:0xcb:m -Uhfuse:w:0xd8:m -Ulfuse:w:0xff:m"
};

sub program_board {
    my $device = probe_device();

    # ATMega32u4 0x1e9587
    # ATTiny88 0x1e9311
    # none found: none;

    if ( $device =~ /0x1e9587/i ) {
        print "\n\nFound ATMega32U4\n\n";
        set_atmega_fuses();
        flash_atmega_device();
        print "DONE!\n\n";

    }
    elsif ( $device =~ /0x1e9311/i ) {
        print "\n\nFound ATTiny88\n\n";
        set_attiny_fuses();
        flash_attiny_device();
        print "DONE!\n\n";
    }
    else {
        print "\n\nERROR: NO board\n\n";
    }

}

sub set_atmega_fuses {
    print "Fuse...";
    my ( $output, $error, $exit ) = run_avrdude( "atmega32u4", split(/\s+/,$fuses->{'atmega32u4'})
    );

    if ($exit) {
        error("could not set fuses on atmega");
    }
    else {
        print "OK \n";
    }
}

sub flash_atmega_device {
    print "Program...";
    my ( $output, $error, $exit ) = run_avrdude( "atmega32u4",
        qw"-B 1", "-Uflash:w:".  $firmware->{'atmega32u4'}.":i", qw"-Ulock:w:0xEF:m"
    );
    if ($exit) {
        error("FAIL");
    }
    else {
        print "OK \n";
    }
}

sub set_attiny_fuses {
    print "Fuse...";
    my ( $output, $error, $exit ) = run_avrdude( "attiny88", split(/\s+/,$fuses->{'attiny88'}) );

    if ($exit) {
        error("FAIL");
    }
    else {
        print "OK\n";
    }
}

sub flash_attiny_device {
    print "Program...";
    my ( $output, $error, $exit ) = run_avrdude( "attiny88",
        qw"-B 1 -U",  "flash:w:". $firmware->{'attiny88'} .":i" );
    if ($exit) {
        error("FAIL");
    }
    else {
        print "OK\n";
    }

}

sub run_avrdude {
    my $device  = shift;
    my @command = @_;
    my ( $in, $out, $err, $exitcode );

    my @cmd = ( 'avrdude', '-v', "-p$device", "-cusbtiny", "-q", @command );

    #  print join(" ","\n",@cmd, "\n");
    eval {
        IPC::Run::run( \@cmd, \$in, \$out, \$err );

    };
    if ($@) {

        # Could not run the program
        $exitcode = undef;
    }
    else {
        $exitcode = $? >> 8;
    }

    # my $output = join("",`avrdude -v -p$device -cusbtiny -q $command 2>&1`);
    #	print $in . "\n";
    #	print $out."\n";
    #	print $err ."\n";
    #warn "Exit code is $exitcode";
    return ( $out, $err, $exitcode );

    #return $output;
}

sub probe_device {

    my ( $output, $error, $exit ) = run_avrdude( "m8", "" );
    if ( $error =~ /Device signature = (\S*)/ ) {
        my $chip = $1;
        return $chip;
    }

    return "none";
}

sub error {
    my $message = shift;
    die $message;
}

sub prompt_to_start {
    while (1) {
        print "\n\n\nConnect a board and then press any key.\n";
	ReadMode(4);
        my $nothing = ReadKey();
	ReadMode(0);
	if ($nothing eq '_') { exit(0)};
        eval { program_board(); };
    }

}

prompt_to_start();
