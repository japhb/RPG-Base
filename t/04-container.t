use Test;
use RPG::Base::Container;


plan 42;


{
    my $backpack = RPG::Base::Container.new(:name('backpack'));
    my $flask    = RPG::Base::Container.new(:name('flask'));
    my $bag      = RPG::Base::Container.new(:name('bag'));
    my @all      = $backpack, $flask, $bag;

    isa-ok $_,  RPG::Base::Container      for @all;
    isa-ok $_,  RPG::Base::Thing          for @all;
    does-ok $_, RPG::Base::ThingContainer for @all;

    $backpack.add-thing($flask);
    $backpack.add-thing($bag);
    my @contents = $flask, $bag;

    ok .container === $backpack, "backpack is {$_}.container" for @contents;
    ok $_ ∈ $backpack.contents,  "$_ is in backpack contents" for @contents;
    ok $backpack.contains($_),   "backpack contains $_"       for @contents;
    nok .contents,               "$_ has no contents"         for @contents;

    ok .Str.contains(.name),           "$_ mentions its name in default .Str"  for @all;
    nok .Str.contains('('),            "$_ has no parentheses in default .Str" for @contents;
    ok .gist.contains(.name),          "$_ mentions its name in default .gist" for @all;
    ok .gist.contains(.^name),         "$_ mentions its type in default .gist" for @all;
    ok .gist.contains('backpack'),     "$_ mentions backpack in default .gist" for @contents;
    ok $backpack.gist.contains(.name), "backpack mentions $_ in default .gist" for @contents;
    ok $backpack.Str.contains(.name),  "backpack mentions $_ in default .Str"  for @contents;

    $backpack.remove-thing($flask);
    nok $flask ∈ $backpack.contents, "removed flask from backpack";
    nok $backpack.contains($flask),  "backpack no longer contains flask";
    nok $flask.container,            "flask has no container";

    $bag.add-thing($flask);
    ok $flask ∈ $bag.contents,       "flask added to bag";
    nok $flask ∈ $backpack.contents, "flask not directly inside backpack";
    ok $flask.container === $bag,    "bag is flask's container";
    ok $bag.contains($flask),        "bag contains flask";
    ok $backpack.contains($flask),   "backpack contains flask recursively";
}


done-testing;
