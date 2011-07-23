use strictures 1;
package Fungi::Framework::Dancer;
use Moo;
extends 'Fungi::Framework';

sub _build_preamble {
    my $self = shift;
    
    my $app_name = lc($self->app_name);
    return qq{
set 'logger'      => 'console';
set 'log'         => 'debug';
set 'show_errors' => 1;
set 'access_log'  => 1;
        
before sub {
    var ${app_name} => request->env->{${app_name}};
};
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