use strictures 1;
package Fungi::Role::Spec;
use Moo::Role;
use Mojito::Types;

has 'app_name' => (
    is => 'ro',
    isa => Mojito::Types::NoRef,
    required => 1,
);

has 'fungi_spec_file' => (
    is => 'ro',
    isa => Mojito::Types::NoRef,
    'default' => sub { '/home/hunter/dev/Mojito/script/mojito.wtf-gi.pl' },
);

has 'fungi_spec' => (
    is => 'ro',
    isa => Mojito::Types::ArrayRef,
    lazy => 1,
    builder => '_build_fungi_spec',
);

has 'spore_spec_file' => (
    is => 'ro',
    isa => Mojito::Types::NoRef,
);

has 'spore_spec' => (
    is => 'ro',
    isa => Mojito::Types::ArrayRef,
);

=head2 _build_fungi_spec

Read the WTF-GI Application specification file.

=cut

sub _build_fungi_spec {
    my $self = shift;
    
    # TODO: make param to handle arbitrary path
    my $spec_file  = $self->fungi_spec_file;

    # Config
    my $spec = [];
    if ( -r $spec_file ) {
        unless ( $spec = do $spec_file ) {
            die qq/Can't load config file "$spec_file": $@/ if $@;
            die qq/Can't load config file "$spec_file": $!/ unless defined $spec;
        }
    }

    return $spec;
}
