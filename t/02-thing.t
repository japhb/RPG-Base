use Test;
use RPG::Base::Thing;


plan 10;


{
    # Anonymous thing
    my $thing = RPG::Base::Thing.new;
    isa-ok $thing, RPG::Base::Thing;
    is $thing.name, 'unnamed', "anon thing got default name";
    nok $thing.container, "anon thing starts with no container";
    like $thing.gist, /'RPG::Base::Thing'/,    "anon thing mentions its type in default .gist";
    like $thing.gist, /'without a container'/, "anon thing mentions lack of container in default .gist";
}

{
    # Named thing
    my $thing = RPG::Base::Thing.new(:name('Thingy'));
    isa-ok $thing, RPG::Base::Thing;
    is $thing.name, 'Thingy', "named thing knows its name";
    nok $thing.container, "named thing starts with no container";
    like $thing.gist, /'RPG::Base::Thing'/,    "named thing mentions its type in default .gist";
    like $thing.gist, /'without a container'/, "named thing mentions lack of container in default .gist";
}


done-testing;
