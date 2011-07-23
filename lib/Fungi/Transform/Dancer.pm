use strictures 1;
package Fungi::Transform::Dancer;
use Moo;
extends 'Fungi::Transform';
use Data::Dumper::Concise;


sub transform {
    my ($self, $message) = (shift, shift);

    my $response = '';
    my $app_name = lc $self->app_name;
    if ( $message->{response_type} eq 'html' ) {
        $response = "return vars->{$app_name}" . '->' . $message->{response} . '($params)';
    }
    elsif ( $message->{response_type} eq 'redirect' ) {
        $response = "redirect  vars->{$app_name}" . '->' . $message->{response} . '($params)';
    }
    elsif ( $message->{response_type} =~ m/json/i ) {
      $response = "to_json(  vars->{$app_name}" . '->' . $message->{response}  . '($params)' . ' )';
    }
    
    # Empty parenthesis following the response handler name indicate no params needed/wanted.
    if ( $message->{response} =~ m/\(\)$/ ) {
        $response =~ s/\(\$params\)//;
    }
    # A semi-colon after the response handler indicate we want to call an attribute, thus no parenthesis needed.
    elsif ( $message->{response} =~ m/;$/ ) {
        $response =~ s/;\(\$params\)//;
    }    
    else {
        $response =~ s/\$params/scalar params/;
    }
    
    # Turn on public var when route has public in it
    if ( $message->{route} =~ m|^/public/| ) {
        $response = "params->{public} = 1;\n    " . $response;
    }

    my $route_body = <<"END_BODY";
$message->{request_method} '$message->{route}' => sub {
    $response;
};
END_BODY

    return $route_body;
}

1