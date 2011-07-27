use strictures 1;
use 5.010;
use Fungi::Framework::Dancer;
use Fungi::Transform::Dancer;
use Data::Dumper::Concise;

my $app = 'Mojito';
my $dancer = Fungi::Framework::Dancer->new(app_name => $app);
say $dancer->use_modules;
say $dancer->preamble;

my $messages = $dancer->fungi_spec;
my $transformer = Fungi::Transform::Dancer->new(app_name => $app);
foreach my $message (@{$messages}) {
    say $transformer->transform($message);
}

say $dancer->builder;

#say Dumper $dancer->fungi_spec;
