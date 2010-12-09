package Acme::CheckCharactorsOutsideRange;

use strict;
use warnings;
use 5.00801;
use Carp ();
use Filter::Util::Call ();
use Encode qw/find_encoding decode_utf8/;
use PPI::Document;

my $default = find_encoding 'utf8';

our $VERSION = '0.01';

sub import {
    my $class = shift;
    my $encoder = shift || $default;
    $encoder = ref($encoder) =~ /Encode::/ ? $encoder : find_encoding $encoder;
    
    my ($file, $line) = (caller(0))[1, 2];
    warn $file;
    
    Filter::Util::Call::filter_add(sub {
        my $status;
        my $code = '';
        my $count = 0;
        while ($status = Filter::Util::Call::filter_read()) {
            return $status if $status < 0;
            
            $count++;
            
            if (/[^\w]/) {
                {
                    local $@;
                    eval { $encoder->encode( decode_utf8($_), 1 ) };
                    if ($@) {
                        my $msg = $@;
                        $msg =~ s/ at .*\n//;
                        $msg = sprintf "$msg at $file line %d", $line + $count;
                        
                        CORE::die "$msg\n";
                    }
                }
            }
            
            $code .= $_;
            $_ = "";
        }
        
        if (-f $file) {
            my $doc = PPI::Document->new($file) or die "cannot create PPI::Document for $file: $!";
            my $dq = $doc->find('PPI::Token::Quote::Double') || [];
            my $qq = $doc->find('PPI::Token::Quote::Interpolate') || [];
            
            for my $elem (@$dq, @$qq) {
                my $content = $elem->content;
                while ($content =~ s/\\x\{(\d{4})\}//) {
                    my $char = decode_utf8 pack U => hex $1;
                    
                    local $@;
                    eval { $encoder->encode( $char, 1 ) };
                    if ($@) {
                        my $msg = $@;
                        $msg =~ s/ at .*\n//;
                        
                        CORE::die "$msg at $file\n";
                    }
                }
            }
        }
        
        $_ = $code;
        
        return $count;
    });
    
    return 1;
}

1;
__END__

=encoding utf-8

=head1 NAME

Acme::CheckCharactorsOutsideRange - If the script contains characters outside the range will that die.

=head1 SYNOPSIS

  use Acme::CheckCharactorsOutsideRange 'cp932' # default utf8;
  
  my $char = "\x{2600}" # die!!

=head1 DESCRIPTION

Acme::CheckCharactorsOutsideRange is

=head1 AUTHOR

Yuji Shimada E<lt>xaicron {at} gmail.comE<gt>

=head1 SEE ALSO

L<Filter::Util::Call>, L<PPI>, L<Encode>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
