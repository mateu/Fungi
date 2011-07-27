use strictures 1;
package Fungi::Transform::Spore;
use 5.010;
use Moo;
use JSON ();
use Data::Dumper::Concise;

extends 'Fungi::Transform';


=head1 METHODS

=head2 fungi_to_spore

Take a Fungi spec and turn it into a Spore spec

=cut

sub fungi_to_spore {
    my ($self, $fungi_spec) = @_;
    
    $fungi_spec //= $self->fungi_spec;
    die "No Fungi spec" if !$fungi_spec;
    
    # Need to create methods data structure
    # Check for response key at highest level
    # OR check for response key within a GET, POST, PUT, DELETE key
    my %methods;
    foreach my $message (@{$self->fungi_spec}) {
        if ($message->{response}) {
            $methods{$self->standardize_response_method($message->{response})} = 
            {
                path => $message->{route},
                method => $message->{request_method},
            };
        }
    }
    my $spore_spec = {
        name    => $self->app_name,
        methods => \%methods,
    };
    
    return JSON->new->encode($spore_spec);
}

=head2 spore_to_fungi

Take a Spore spec and turn it into a Fungi spec

=cut

sub spore_to_fungi {
    my ($self, $spore_spec) = @_;
    
    $spore_spec //= $self->spore_spec;
    die "No Spore spec" if !$spore_spec;
    
    my $spec_hashref = JSON::decode_json($spore_spec);
	my $messages = [];
	foreach my $handler (keys %{$spec_hashref->{methods}} ) {
		my $message = {
			route => $spec_hashref->{methods}->{$handler}->{path},
			response =>  $handler,
			request_method =>  $spec_hashref->{methods}->{$handler}->{method},
		};
		push @{$messages}, $message;
	}

	return $messages;
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
