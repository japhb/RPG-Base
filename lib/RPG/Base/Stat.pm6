role RPG::Base::Stat { ... };


# Exceptions specific to these roles
class X::RPG::Base::Stat::UndefinedBase is Exception {
    has RPG::Base::Stat:D $.relative is required;
    has Str:D             $.base     is required;

    method message() {
        "Cannot determine value of relative stat '$.relative.name()'; base stat '$.base' does not have a defined value"
    }
}


#| A basic stat role, used for constraints
role RPG::Base::Stat {
    has Str:D $.name is required;

    method value($stats-bearer) { ... }
}


#| A basic stat: just a value and a default for that value
role RPG::Base::BasicStat[::T = Int]
does RPG::Base::Stat {
    has T $.default;
    has T $.value;

    method set-value(T $new)    { $!value = $new }
    method set-to-default()     { $!value = $!default }
    method value($stats-bearer) { $!value }
}


#| A stat whose value is a delta relative to some other stat
role RPG::Base::RelativeStat[::T = Int]
does RPG::Base::Stat {
    has Str:D $.base  is required;
    has T:D   $.delta = T.new;

    # Invariant checkers
    method !throw-unless-base-defined($base, $value) {
        X::RPG::Base::Stat::UndefinedBase.new(:relative(self), :$.base).throw
            unless $value.defined;
    }

    method set-delta(T:D $new)  { $!delta = $new }
    method value($stats-bearer) {
        my $base-value = $stats-bearer.stat($.base);
        self!throw-unless-base-defined($.base, $base-value);

        $base-value + $.delta
    }
}


#| A stat whose value is computed on the fly from other stats
role RPG::Base::ComputedStat
does RPG::Base::Stat {
    has &.code is required;

    method value($stats-bearer) { &!code($stats-bearer) }
}
