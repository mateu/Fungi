use strictures 1;
package Fungi::Transform::Spore;
use 5.010;
use Moo;
use JSON ();

extends 'Fungi::Transform';

use Data::Dumper::Concise;

has 'fungi_spec' => (
    is => 'rw',
);

has 'spore_spec' => (
    is => 'rw',
);

=head1 METHODS

=head2 fungi_to_spore

Take a Fungi spec and turn it into a Spore spec

=cut

sub fungi_to_spore {
    my $self = shift;
    
    die "No Fungi spec" if !$self->spec;
    
    # Need to create methods data structure
    # Check for response key at highest level
    # OR check for response key within a GET, POST, PUT, DELETE key
    my %methods;
    foreach my $message (@{$self->spec}) {
        if ($message->{response}) {
            $methods{$self->standardize_response_method($message->{response})} = 
            {
                path => $message->{route},
                method => $message->{request_method},
            };
        }
    }
    my $spore_spec = {
        name => $self->app_name,
        methods => \%methods,
    };
    
    return JSON::encode_json($spore_spec);
}

=head2 spore_to_fungi

Take a Spore spec and turn it into a Fungi spec

=cut

sub spore_to_fungi {
    my $self = shift;
    
    return;
}

sub standardize_response_method {
    my ($self, $response) = @_;
    
    # Remove trailing colon
    $response =~ s/;$//;
    
    # Remove trailing parenthesis
    $response =~ s/\(\)$//;

    return $response;
}

1