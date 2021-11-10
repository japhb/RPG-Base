use RPG::Base::Stat;
use RPG::Base::StatModifier;


role RPG::Base::StatsBearer {...};


# Exceptions specific to this role
class X::RPG::Base::StatsBearer::StatUnknown is Exception {
    has                        $.stat;
    has RPG::Base::StatsBearer $.bearer;

    method message() {
        "Stat '$.stat' is unknown to $.bearer.^name() '$.bearer'"
    }
}

class X::RPG::Base::StatsBearer::StatExists is Exception {
    has                        $.stat;
    has RPG::Base::StatsBearer $.bearer;

    method message() {
        "Stat '$.stat' already exists for $.bearer.^name() '$.bearer'"
    }
}

# XXXX: Currently unused
class X::RPG::Base::StatsBearer::StatUnset is Exception {
    has                        $.stat;
    has RPG::Base::StatsBearer $.bearer;

    method message() {
        "Stat '$.stat' is not set for $.bearer.^name() '$.bearer'"
    }
}

class X::RPG::Base::StatsBearer::StatComputed is Exception {
    has                        $.stat;
    has RPG::Base::StatsBearer $.bearer;

    method message() {
        "Stat '$.stat' is computed for $.bearer.^name() '$.bearer', and cannot be directly set or modified"
    }
}

class X::RPG::Base::StatsBearer::NotActive is Exception {
    has RPG::Base::StatModifier $.modifier;
    has RPG::Base::StatsBearer  $.bearer;

    method message() {
        "$.modifier.^name() '$.modifier' is not active for $.bearer.^name() '$.bearer'"
    }
}


#| A thing that has measurable (and modifiable) stats
role RPG::Base::StatsBearer {
    has %!stats;
    has @.modifiers;


    submethod BUILD() {
        self.add-all-stats;
    }

    # Invariant checkers
    method !throw-if-stat-unknown($stat) {
        X::RPG::Base::StatsBearer::StatUnknown.new(:$stat, :bearer(self)).throw
            unless %!stats{$stat}:exists;
    }

    method !throw-if-stat-exists($stat) {
        X::RPG::Base::StatsBearer::StatExists.new(:$stat, :bearer(self)).throw
            if %!stats{$stat}:exists;
    }

    # XXXX: Currently unused
    method !throw-if-stat-unset($stat) {
        X::RPG::Base::StatsBearer::StatUnset.new(:$stat, :bearer(self)).throw
            unless %!stats{$stat}.defined;
    }

    method !throw-if-stat-computed($stat) {
        X::RPG::Base::StatsBearer::StatComputed.new(:$stat, :bearer(self)).throw
            if %!stats{$stat} ~~ RPG::Base::ComputedStat;
    }

    method !throw-unless-modifier-active($modifier) {
        X::RPG::Base::StatsBearer::NotActive.new(:$modifier, :bearer(self)).throw
            unless $modifier ∈ @!modifiers;
    }


    #| Add all predefined types of stats, called by submethod BUILD.  If not
    #| overriden, default behavior is to use the {base,computed,relative}-stats
    #| methods to feed stat definitons to the add-{known,computed,relative}-stats
    #| methods, in that order.
    method add-all-stats() {
        self.add-known-stats(   self.base-stats    );
        self.add-computed-stats(self.computed-stats);
        self.add-relative-stats(self.relative-stats);
    }

    #| Non-computed stats recognized by all instances of this class, by default
    #| as stat-name => default pairs (see add-known-stats); override in classes
    #| to supply starting stat definitions
    method base-stats() {
        ()
    }

    #| Stats computed in this class, by default as stat-name => code pairs (see
    #| add-computed-stats); override in classes to supply starting stat definitions
    method computed-stats() {
        ()
    }

    #| Stats whose value is relative to another stat, by default as
    #| stat-name => base-name pairs (see add-relative-stats); override in classes
    #| to supply starting stat definitions
    method relative-stats() {
        ()
    }

    #| Add additional known stats, by default expecting stat-name => default pairs
    method add-known-stats(@pairs) {
        for @pairs {
            my $type = .value.WHAT;
            my $stat = RPG::Base::BasicStat[$type].new(:name(.key),
                                                       :default(.value),
                                                       :value($type));
            self.add-stat($stat);
        }
    }

    #| Add additional computed stats, by default expecting stat-name => code pairs
    method add-computed-stats(@pairs) {
        for @pairs {
            my $stat = RPG::Base::ComputedStat.new(:name(.key), :code(.value));
            self.add-stat($stat);
        }
    }

    #| Add additional relative stats, by default expecting stat-name => base-name pairs
    method add-relative-stats(@pairs) {
        for @pairs {
            self!throw-if-stat-unknown(.value);

            # XXXX: Autodetecting type when base value has not been set?
            my $stat = RPG::Base::RelativeStat.new(:name(.key), :base(.value));
            self.add-stat($stat);
        }
    }

    #| Add an RPG::Base::Stat instance directly
    method add-stat(RPG::Base::Stat:D $stat) {
        my $name = $stat.name;
        self!throw-if-stat-exists($name);

        %!stats{$name} = $stat;
    }

    #| Find matching modifiers in the modifier stack
    method modifiers-matching(Mu $matcher) {
        my @ = @!modifiers.grep($matcher)
    }

    #| Add modifier to modifier stack
    method add-modifier(RPG::Base::StatModifier:D $modifier) {
        self!throw-if-stat-unknown($modifier.stat);

        @!modifiers.push($modifier);
    }

    #| Remove a modifier from the modifier stack
    method remove-modifier(RPG::Base::StatModifier:D $modifier) {
        self!throw-unless-modifier-active($modifier);

        @!modifiers.splice(@!modifiers.first($modifier, :k), 1);
    }

    #| Apply modifiers to a given stat value; override in subclasses to e.g. redefine stacking behavior
    method apply-modifiers($stat, $value is copy) {
        $value += .change if .stat eq $stat for @!modifiers;
        $value
    }

    #| Set the base value for an already-known stat
    method set-base-stat($stat, $value) {
        self!throw-if-stat-unknown($stat);
        self!throw-if-stat-computed($stat);

        %!stats{$stat}.set-value($value);
    }

    #| Set unset base stats to their defaults
    method set-stats-to-defaults() {
        for %!stats.values.grep(RPG::Base::BasicStat) {
            .set-to-default unless .value(self).defined;
        }
    }

    #| Retrieve all stat objects (presumably for iteration)
    method stats() {
        %!stats.values
    }

    #| Retrieve raw stat object by name
    method raw-stat($name) {
        self!throw-if-stat-unknown($name);

        %!stats{$name}
    }

    #| Retrieve base (unmodified) value for a stat
    method base-stat($stat) {
        self!throw-if-stat-unknown($stat);

        %!stats{$stat}.value(self)
    }

    #| Calculate fully modified value for a stat
    method stat($stat) {
        self.apply-modifiers($stat, self.base-stat($stat))
    }
}
