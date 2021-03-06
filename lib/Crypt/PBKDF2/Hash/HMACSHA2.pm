package Crypt::PBKDF2::Hash::HMACSHA2;
# ABSTRACT: HMAC-SHA2 support for Crypt::PBKDF2 using Digest::SHA

use Moose 1;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use Digest::SHA ();

with 'Crypt::PBKDF2::Hash';

subtype 'SHASize' => (
  as 'Int',
  where { $_ == 224 or $_ == 256 or $_ == 384 or $_ == 512 },
  message { "$_ is an invalid number of bits for SHA-2" }
);

has 'sha_size' => (
  is => 'ro',
  isa => 'SHASize',
  default => 256,
);

has '_hasher' => (
  is => 'ro',
  lazy_build => 1,
  init_arg => undef,
);

sub _build__hasher {
  my $self = shift;
  my $shasize = $self->sha_size;

  return Digest::SHA->can("hmac_sha$shasize");
}

sub hash_len {
  my $self = shift;
  return $self->sha_size() / 8;
}

sub generate {
  my $self = shift; # ($data, $key)
  return $self->_hasher->(@_);
}

sub to_algo_string {
  my $self = shift;

  return $self->sha_size;
}

sub from_algo_string {
  my ($class, $str) = @_;

  return $class->new( sha_size => $str );
}

__PACKAGE__->meta->make_immutable;
1;

=head1 DESCRIPTION

Uses L<Digest::SHA> C<hmac_sha256>/C<hmac_sha384>/C<hmac_sha512> to provide
the HMAC-SHA2 family of hashes for L<Crypt::PBKDF2>.
