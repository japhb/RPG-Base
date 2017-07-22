NAME
====

`RPG::Base` - Common base components for RPGs

SYNOPSIS
========

    use RPG::Base::Container;
    use RPG::Base::Creature;
    use RPG::Base::Location;
    use RPG::Base::Thing;

    # Using the base classes directly
    my $bob      = RPG::Base::Creature.new(:name('Bob the Magnificent'));
    my $backpack = RPG::Base::Container.new(:name('Cloth Backpack'));
    my $flint    = RPG::Base::Thing.new(:name('Flint and Steel'));
    my $wand     = RPG::Base::Thing.new(:name('Ironwood Wand'));

    my $clearing = RPG::Base::Location.new(:name('Grassy Clearing'));
    my $grove    = RPG::Base::Location.new(:name('Oak Grove'));
    my $cliff    = RPG::Base::Location.new(:name('Sheer Cliff'));

    $backpack.add-thing($flint);
    $bob.add-thing($_) for $backpack, $wand;

    $grove   .add-exit('north' => $clearing);
    $cliff   .add-exit('down'  => $clearing);
    $clearing.add-exit('south' => $grove);
    $clearing.add-exit('up'    => $cliff);
    $clearing.add-thing($bob);

    $clearing.say;  # "Grassy Clearing (exits: 2, things: 1)"
    $bob.say;       # "Bob the Magnificent (RPG::Base::Creature in
                    #  RPG::Base::Location 'Grassy Clearing' carrying
                    #  Cloth Backpack (contents: Flint and Steel),
                    #  Ironwood Wand)"

DESCRIPTION
===========

`RPG::Base` is a set of common base concepts and components on which more complex RPG rulesets can be based. It limits itself to those concepts that are near universal across RPGs (though some games use different terminology, `RPG::Base` simply chooses common terms knowing that game-specific subclasses can be named using that game's particular terminology).

The entire point of `RPG::Base` is to be subclassable, extensible, and generic. If it turns out that one of the design choices is making that difficult, **please let me know**.

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2016-2017 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
