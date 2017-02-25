package Log::Any::Adapter::Dispatch;
# ABSTRACT: Adapter to use Log::Dispatch with Log::Any
our $VERSION = '0.09';

use Log::Any::Adapter::Util qw(make_method);
use Log::Dispatch;
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

sub init {
    my $self = shift;

    # If a dispatcher was not explicitly passed in, create a new one with the passed arguments.
    #
    $_[-2] eq "category" and splice @_, -2, 2;
    $self->{dispatcher} ||= Log::Dispatch->new(@_);
}

# Delegate logging methods to same methods in dispatcher
#
foreach my $method ( Log::Any->logging_methods() ) {
    my $log_dispatch_method = $method;
    $log_dispatch_method =~ s/trace/debug/;
    __PACKAGE__->delegate_method_to_slot( 'dispatcher', $method,
        $log_dispatch_method );
}

# Delegate detection methods to would_log
#
foreach my $method ( Log::Any->detection_methods() ) {
    my $level = substr( $method, 3 );
    $level =~ s/trace/debug/;
    make_method( $method,
        sub { my ($self) = @_; return $self->{dispatcher}->would_log($level) }
    );
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Log::Any::Adapter;

    Log::Any::Adapter->set('Dispatch', outputs => [[ ... ]]);

    my $dispatcher = Log::Dispatch->new( ... );
    Log::Any::Adapter->set('Dispatch', dispatcher => $dispatcher);

=head1 DESCRIPTION

This L<Log::Any|Log::Any> adapter uses L<Log::Dispatch|Log::Dispatch> for
logging.

You may either pass parameters (like I<outputs>) to be passed to
C<Log::Dispatch-E<gt>new>, or pass a C<Log::Dispatch> object directly in the
I<dispatcher> parameter.

=head1 SEE ALSO

L<Log::Any::Adapter|Log::Any::Adapter>, L<Log::Any|Log::Any>,
L<Log::Dispatch|Log::Dispatch>

=cut
