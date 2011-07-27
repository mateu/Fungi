use strictures 1;
use 5.010;
use Fungi::Transform::Spore;

use Data::Dumper::Concise;

my $spore_transform = Fungi::Transform::Spore->new(app_name => 'Mojito');
my $spore_spec = $spore_transform->fungi_to_spore;
say Dumper $spore_transform->spore_to_fungi($spore_spec);
