use strictures 1;
package Fungi::Framework::Dancer;
use Moo;
extends 'Fungi::Framework';

sub _build_preamble {
    my $self = shift;
    
    my $app_name = lc($self->app_name);
    return qq{
my (\$${app_name});
before sub {
    \$${app_name} = request->env->{${app_name}};
    var ${app_name} => \$${app_name};
}
};
}

sub builder {
    my $self = shift;
    
    my $original_builder = $self->SUPER::builder;
    $original_builder =~ s/<start_app\/>/dance;/;

    return $original_builder;
}

sub modules_to_use {
    my $self = shift;
    
    my @modules = @{$self->SUPER::modules_to_use};
    my $framework = __PACKAGE__;
    $framework =~ s/.*\://;
    unshift @modules, $framework;

    return [@modules];
}


1