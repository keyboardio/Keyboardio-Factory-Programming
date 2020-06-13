#!/usr/bin/perl
use warnings;
use strict;
use IPC::Run;
use Term::ReadKey;

my $os = `uname`;
chomp($os);

my $firmware_dir = "firmware/";

my $firmware = {
    atmega32u4 => $firmware_dir . "atmega.hex",
    attiny88   => $firmware_dir . "attiny.hex"
};

#http://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny88&LOW=4E&HIGH=DD&EXTENDED=FE&LOCKBIT=FF
my $fuses = {
    attiny88 => "-e -Ulfuse:w:0xeE:m -Uhfuse:w:0xDD:m -Uefuse:w:0xFE:m",
    atmega32u4 =>
      "-e -Ulock:w:0x3F:m -Uefuse:w:0xcb:m -Uhfuse:w:0xd8:m -Ulfuse:w:0xff:m"
};

sub program_boards {
    if ( $os ne 'Darwin' ) {
        my @usbtiny_devices = probe_devices();
        if ( scalar @usbtiny_devices != 3 ) {
            print "ERROR: I only see " . ( scalar @usbtiny_devices ) . "red programmers\n";
            print "ERROR: " . ( 3 - ( scalar @usbtiny_devices ) ) . " are not here\n";
            print "ERROR: Check USB cables\n";
            print "ERROR: Check switches on red boards\n";
        }
        my $boards_programmed = 0;
        eval {
            for my $addr (@usbtiny_devices) {
                print $boards_programmed+ 1 . ": ";
                program_board($addr);
                $boards_programmed++;
            }
        };
        if ( my $msg = $@ ) {
            print "ERROR: programmed $boards_programmed chips\n";
            die $msg;
        }
        if ( $boards_programmed < 3 ) {
            die "Only programmed $boards_programmed chips\n";
        }
        else {
            print "\n\nDONE! All 3 chips programmed.\n";
        }
    }
    else {
        eval { program_board('no_address'); };
        if ( my $msg = $@ ) {
            error("Something went wrong with flashing");
        }
        else {
            print "\n\nDONE! Chip programmed.\n";
        }

    }
}

sub program_board {
    my $addr   = shift;
    my $device = probe_device($addr);

    # ATMega32u4 0x1e9587
    if ( $device =~ /0x1e9587/i ) {
        print "ATMega32U4...";
        set_atmega_fuses($addr);
        flash_atmega_device($addr);
        print "\n";

    }

    # ATTiny88 0x1e9311
    elsif ( $device =~ /0x1e9311/i ) {
        print "ATTiny88...  ";
        set_attiny_fuses($addr);
        flash_attiny_device($addr);
        print "\n";
    }
    else {
        error("I do not see a chip");
    }

}

sub set_atmega_fuses {
    my $addr = shift;
    print "Fuses...";
    my ( $output, $error, $exit ) = run_avrdude( $addr, "atmega32u4", split( /\s+/, $fuses->{'atmega32u4'} ) );
    die_on_failure( $exit, "could not set fuses on atmega" );
}

sub flash_atmega_device {
    my $addr = shift;
    print "Program...";
    my ( $output, $error, $exit ) = run_avrdude( $addr, "atmega32u4", qw"-B 1", "-Uflash:w:" . $firmware->{'atmega32u4'} . ":i", qw"-Ulock:w:0x2F:m" );
    die_on_failure( $exit, "FAIL - flashing ATMega32u4: \n$error\n" );
}

sub set_attiny_fuses {
    my $addr = shift;
    print "Fuses...";
    my ( $output, $error, $exit ) = run_avrdude( $addr, "attiny88", split( /\s+/, $fuses->{'attiny88'} ) );
    die_on_failure( $exit, "FAIL - setting attiny88 fuses: \n$error\n" );
}

sub die_on_failure($$) {
    my $code         = shift;
    my $fail_message = shift;
    if ($code) {
        error($fail_message);
    }
    else {
        print "OK. ";
    }

}

sub flash_attiny_device {
    my $addr = shift;
    print "Program...";
    my ( $output, $error, $exit ) = run_avrdude( $addr, "attiny88", qw"-B 1 -U", "flash:w:" . $firmware->{'attiny88'} . ":i" );
    die_on_failure( $exit, "FAIL - flashing attiny88" );
}

sub reset_usb_bus {

# This total hack resets the USB bus so that if the avrisp got wedged, it forces a reset and starts things up again.
# Source:
# https://unix.stackexchange.com/questions/208129/how-to-power-cycle-a-usb-device-on-beagleboneblack
    system("echo 1 > /sys/bus/usb/devices/usb1/bConfigurationValue");
    sleep(1);
}

sub run_avrdude {
    my $addr    = shift;
    my $device  = shift;
    my @command = @_;
    my ( $in, $out, $err, $exitcode );

    $ENV{'MALLOC_CHECK_'} = '0';

    my @cmd;
	if ($addr eq 'no_device') {
 		@cmd = ( 'avrdude', '-v', "-p$device","-cusbasp", "-q", @command );
	} else {
 		@cmd = ( 'avrdude', '-v', "-p$device", "-P$addr", "-cusbasp", "-q", @command );
	}

    eval {
        IPC::Run::run( \@cmd, \$in, \$out, \$err );

    };
    if ($@) {
        $err .= $@;

        # Could not run the program
        $exitcode = undef;
    }
    else {
        $exitcode = $? >> 8;
    }

    return ( $out, $err, $exitcode );
}

sub probe_device {
    my $addr = shift;
    my ( $output, $error, $exit ) = run_avrdude( $addr, "m8", "" );
    if ( $error =~ /Device signature = (\S*)/ ) {
        my $chip = $1;
        return $chip;
    }

    return "none";
}

sub error {
    my $message = shift;
    die "ERROR: ". $message ."\n";
}

sub prompt_to_start {
    sleep(10);
    system("clear");
    while (1) {
        print "\n\n\nConnect a board. Then press a key.\n";
        ReadMode(4);
        my $nothing = ReadKey();
        ReadMode(0);
        if ( $nothing eq '_' ) { exit(0) }
        if ( $nothing eq 'x' ) { exit(0) }
        if ( $nothing eq 'q' ) { exit(0) }
        system("clear");
        eval { program_boards(); };
        if ( my $msg = $@ ) {
            warn "\n\nERROR: $msg";
        }
    }

}

sub probe_devices {
    reset_usb_bus();
    sleep(2);
    my ( $in, $out, $err );

    #usbtiny
    # my @data = `lsusb -d 1781:0c9f`;
    #usbasp
    my @data = `lsusb -d 16c0:05dc`;
    my @devices;
    for my $line (@data) {
        if ( $line =~ /^Bus (\d+) Device (\d+)(.*?)/mi ) {
            my $bus    = $1;
            my $device = $2;
            push @devices, "usb:$bus:$device";
        }
    }
    return @devices;
}

prompt_to_start();
