use Test;
use RPG::Base::Thing;


plan 6;

{
    # Anonymous thing
    my $thing = RPG::Base::Thing.new;
    isa-ok $thing, RPG::Base::Thing;
    is $thing.name, 'unnamed', "anon thing got default name";
    nok $thing.container, "anon thing starts with no container";
}

{
    # Named thing
    my $thing = RPG::Base::Thing.new(:name('Thingy'));
    isa-ok $thing, RPG::Base::Thing;
    is $thing.name, 'Thingy', "named thing knows its name";
    nok $thing.container, "named thing starts with no container";
}

done-testing;
