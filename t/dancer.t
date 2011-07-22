use strictures 1;
use 5.010;
use Fungi::Framework::Dancer;
use Fungi::Transform::Dancer;
use Data::Dumper::Concise;

my $dancer = Fungi::Framework::Dancer->new( app_name => 'MyAct' );
say $dancer->use_modules;
say $dancer->preamble;

my $messages = $dancer->spec;
my $transformer = Fungi::Transform::Dancer->new;
foreach my $message (@{$messages}) {
    say $transformer->transform($message);
}

say $dancer->builder;

#say Dumper $dancer->spec;
