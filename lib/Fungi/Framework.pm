use strictures 1;
package Fungi::Framework; 
use Moo;

with 'Fungi::Role::Spec';

has 'modules_to_use' => (
    is => 'ro',
    default => sub {
        return [(
        'Plack::Builder',
        'Mojito',
        'Mojito::Auth',
        )];
    }
);

has 'preamble' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_preamble',
);

sub _build_preamble {
    my $self = shift;
    return;
}

has 'builder' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_builder',
);

sub _build_builder {
    my $self = shift;
    
    my $builder_block =
      q{
builder {  
    enable_if { $_[0]->{PATH_INFO} !~ m/^\/(?:public|favicon.ico)/ }
      "Auth::Digest",
      realm => "Mojito",
      secret => Mojito::Auth::_secret,
      password_hashed => 1,
      authenticator => Mojito::Auth->new->digest_authen_cb;
    enable "+Mojito::Middleware";
    
    <start_app/>
}
      };

    return $builder_block;
}

has pre_builder => (
    is => 'ro',
    lazy => 1,
    builder => '_build_pre_builder',
);

sub _build_pre_builder {
    my $self = shift;
    
    return;
}

has post_builder => (
    is => 'ro',
    lazy => 1,
    builder => '_build_post_builder',
);

sub _build_post_builder {
    my $self = shift;
    
    return;
}

sub use_modules {
    my $self = shift;
    
    my $use_statements = join "\n", map { "use $_;" } @{$self->modules_to_use};
}
1