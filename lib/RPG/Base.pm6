use v6.c;
unit class RPG::Base:ver<0.0.1>;


=begin pod

=head1 NAME

RPG::Base - Common base components for RPGs

=head1 SYNOPSIS

  use RPG::Base;

=head1 DESCRIPTION

RPG::Base is a set of common base concepts and components on which more complex
RPG rulesets can be based.  It limits itself to those concepts that are near
universal across RPGs (though some games use different terminology, RPG::Base
simply chooses common terms knowing that game-specific subclasses can be named
using that game's particular terminology).

=head1 AUTHOR

Geoffrey Broadwell <gjb@sonic.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
