use strictures 1;
use 5.010;
package Fungi::Transform;
use Moo;
use Getopt::Long;
use Data::Dumper::Concise;

with 'Fungi::Role::Spec';

=head1 Usage

    perl -Ilib script/wtf-gi.pl --name PublishPage --transform web_simple
    
=cut

has handler_name => (
    is => 'ro',
);

has transform => (
    is => 'ro',
);

my %transforms = (
    transform_web_simple => \&transform_web_simple,
    transform_dancer     => \&transform_dancer,
    transform_mojo       => \&transform_mojo,
    transform_tatsumaki  => \&transform_tatsumaki,
);

sub get_messages_by_name {
    my ($self, $name, $messages) = @_;
    
    my @pages         = grep { $_->{name} =~ m/^$name$/ } @{$messages};
    my $message_count = scalar @pages;
    die "NEED exactly one or two messages by name. Found ", $message_count
      if ( $message_count != 1 && $message_count != 2 );
      
    return \@pages;
}

sub transform_message_by_framework {
    my ( $message, $framework ) = ( shift, shift );
    my $transformer = 'transform_' . $framework;
    say $transforms{$transformer}->($message);
}

sub transform_mojo {
    my $message = shift;

    my $message_response = $message->{response};
    $message_response =~ s/\$/\$self->/;
    my $response;
    if ( $message->{response_type} eq 'html' ) {
        $response = '$self->render( text => $self->' . $message_response . ' )';
    }
    elsif ( $message->{response_type} eq 'redirect' ) {
        $response = '$self->redirect_to(' . $message_response . ')';
    }
    elsif ( $message->{response_type} =~ m/json/i ) {
        $response = '$self->render( json => $self' . $message_response . ' )';
    }
    my $place_holders;
    if ( my @holders = $message->{route} =~ m/\/\:(\w+)/ ) {
        foreach my $holder (@holders) {
            $place_holders .=
                '$params->{' 
              . $holder
              . '} = $self->param(\''
              . $holder . "');\n";
        }

        #       print Dumper \@holders;
        #       print $place_holders;
    }
    if ($place_holders) {
        chomp($place_holders);
    }
    else {
        $place_holders = "# no place holders";
    }

    my $route_body = <<"END_BODY";
$message->{request_method} '$message->{route}' => sub {
    my (\$self) = (shift);
    my \$params;
    $place_holders
    $response;
};
END_BODY

}

sub transform_tatsumaki {
    my $message = shift;

    my $message_response = $message->{response};
    $message_response =~ s/\$mojito/\$self->request->env->{'mojito'}/;
    my $message_route = $message->{route};
    my ( $args, $params ) = route_handler( $message->{route}, 'tatsumaki' );
    my $request_params = '';
    $request_params =
'@{$params}{ keys %{$self->request->parameters} } = values %{$self->request->parameters};'
      if ( $message->{request_method} =~ m/post/i );
    my $route_body;

    if ( $message->{response_type} eq 'redirect' ) {
        $route_body = <<"END_BODY";
package $message->{name};
use parent qw(Tatsumaki::Handler);

sub $message->{request_method} {
    my (\$self, $args) = \@_;
    $params
    $request_params
    my \$redirect_url = $message_response;
    \$self->response->redirect(\$redirect_url);
}
END_BODY
    }
    elsif ( $message->{response_type} =~ m/json/i ) {
        $route_body = <<"END_BODY";
package $message->{name};
use parent qw(Tatsumaki::Handler);

sub $message->{request_method} {
    my (\$self, $args) = \@_;
    \$self->response->content_type('application/json');
    \$self->write(
        JSON::encode_json(
           $message_response; 
        )
    );
}
END_BODY
    }
    else {
        $route_body = <<"END_BODY";
package $message->{name};
use parent qw(Tatsumaki::Handler);

sub $message->{request_method} {
    my ( \$self, $args ) = \@_;
    $params
    \$self->write($message_response);
}
END_BODY
    }
    return $route_body;
}

sub transform_web_simple {
    my $message = shift;

    my $message_response = $message->{response};
    my $content_type     = "['Content-type', ";
    $content_type .= "'text/html']" if ( $message->{response_type} eq 'html' );
    my $request_method = uc( $message->{request_method} );
    my $message_route  = $message->{route};
    my ( $args, $params ) = route_handler( $message_route, 'simple' );
    $message_route =~ s/\:\w+/*/g;
    $message_route .= ' + %*' if ( $request_method eq 'POST' );
    my $route_body;

    if ( $message->{response_type} eq 'redirect' ) {
        $route_body = <<"END_BODY";
sub ( $request_method + $message_route ) {
    my (\$self, $args) = \@_;
    $params
    my \$redirect_url = $message_response;
    [ 301, [ Location => \$redirect_url ], [] ];
},

END_BODY
    }
    else {
        $route_body = <<"END_BODY";
sub ( $request_method + $message_route ) {
    my (\$self, $args) = \@_;
    $params
    my \$output = $message_response;
    [ $message->{status_code}, $content_type, [\$output] ];
},

END_BODY
    }
    return $route_body;
}

sub route_handler {
    my ( $route, $framework ) = ( shift, shift );

    my ( $args, $params );
    given ($framework) {
        when (/simple|tatsumaki/i) {

            # find placeholders
            my @place_holders = $route =~ m/\:(\w+)/ig;
            my @args = map { '$' . $_ } @place_holders;
            $args = join ', ', @args;
            my @params =
              map { '$params->{' . $_ . '} = $' . $_ . ';' } @place_holders;
            $params = join "\n    ", @params;

            #say "args: $args; params: $params";
        }
    }
    return ( $args, $params );
}


1