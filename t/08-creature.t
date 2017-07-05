use Test;
use RPG::Base::Creature;


plan 6;

{
    # Anonymous creature
    my $creature = RPG::Base::Creature.new;
    isa-ok $creature, RPG::Base::Creature;
    isa-ok $creature, RPG::Base::Thing;
    is $creature.name, 'unnamed', "anon creature got default name";
}

{
    # Named creature
    my $creature = RPG::Base::Creature.new(:name('Zuul'));
    isa-ok $creature, RPG::Base::Creature;
    isa-ok $creature, RPG::Base::Thing;
    is $creature.name, 'Zuul', "named creature knows its name";
}

done-testing;
