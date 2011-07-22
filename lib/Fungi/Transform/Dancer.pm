use strictures 1;
package Fungi::Transform::Dancer;
use Moo;
extends 'Fungi::Transform';
use Data::Dumper::Concise;


sub transform {
    my ($self, $message) = (shift, shift);

    my $response = '';
    if ( $message->{response_type} eq 'html' ) {
        $response = 'return ' . $message->{response};
    }
    elsif ( $message->{response_type} eq 'redirect' ) {
        $response = 'redirect ' . $message->{response};
    }
    elsif ( $message->{response_type} =~ m/json/i ) {
      $response = 'to_json( ' . $message->{response} . ' )';
    }
    $response =~ s/\$params/scalar params/;

    my $route_body = <<"END_BODY";
$message->{request_method} '$message->{route}' => sub {
    $response;
};
END_BODY

    return $route_body;
}

1